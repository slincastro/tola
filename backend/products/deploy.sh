#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRODUCTS_DIR="$ROOT_DIR/backend/products"
TF_DIR="$ROOT_DIR/infrastructure/terraform/environments/dev"
BUILD_DIR="$PRODUCTS_DIR/.build"
DIST_DIR="$PRODUCTS_DIR/dist"
PACKAGE_ZIP="$DIST_DIR/lambda_products.zip"

PYTHON_BIN="${PYTHON_BIN:-python3}"
PIP_BIN="${PIP_BIN:-pip3}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"
RUN_TERRAFORM="${RUN_TERRAFORM:-true}"
RUN_LAMBDA_CODE_UPDATE="${RUN_LAMBDA_CODE_UPDATE:-true}"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd "$PYTHON_BIN"
require_cmd "$PIP_BIN"
require_cmd zip
require_cmd terraform
require_cmd aws

log "Building Lambda package"
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Runtime dependencies used by backend/products app.
"$PIP_BIN" install --quiet --target "$BUILD_DIR" \
  fastapi==0.116.1 \
  mangum==0.19.0 \
  pymongo==4.8.0 \
  pydantic==2.8.2

cp "$PRODUCTS_DIR"/*.py "$BUILD_DIR"/

cat > "$BUILD_DIR/main.py" <<'PYEOF'
from mangum import Mangum
from app import app

handler = Mangum(app)
PYEOF

(
  cd "$BUILD_DIR"
  zip -qr "$PACKAGE_ZIP" .
)

if [[ "$RUN_TERRAFORM" == "true" ]]; then
  log "Running terraform init"
  terraform -chdir="$TF_DIR" init

  log "Running terraform plan"
  terraform -chdir="$TF_DIR" plan

  log "Applying terraform"
  if [[ "$AUTO_APPROVE" == "true" ]]; then
    terraform -chdir="$TF_DIR" apply -auto-approve
  else
    terraform -chdir="$TF_DIR" apply
  fi
fi

LAMBDA_NAME="$(terraform -chdir="$TF_DIR" output -raw lambda_function_name)"
API_URL="$(terraform -chdir="$TF_DIR" output -raw api_gateway_url)"

if [[ "$RUN_LAMBDA_CODE_UPDATE" == "true" ]]; then
  log "Updating Lambda code: $LAMBDA_NAME"
  aws lambda update-function-code \
    --function-name "$LAMBDA_NAME" \
    --zip-file "fileb://$PACKAGE_ZIP" \
    --publish >/dev/null

  log "Waiting for Lambda update to complete"
  aws lambda wait function-updated --function-name "$LAMBDA_NAME"

  # Ensure runtime variable expected by backend/products/mongo.py is present.
  CURRENT_ENV_JSON="$(aws lambda get-function-configuration --function-name "$LAMBDA_NAME" --query 'Environment.Variables' --output json)"
  MONGODB_URI_VALUE="$($PYTHON_BIN -c 'import json,sys; env=json.loads(sys.argv[1]); print(env.get("MONGODB_URI") or env.get("MONGODB_CONNECTION_STRING") or "")' "$CURRENT_ENV_JSON")"

  if [[ -n "$MONGODB_URI_VALUE" ]]; then
    MERGED_ENV_JSON="$($PYTHON_BIN -c 'import json,sys; env=json.loads(sys.argv[1]); uri=sys.argv[2]; env["MONGODB_URI"]=uri; print(json.dumps(env))' "$CURRENT_ENV_JSON" "$MONGODB_URI_VALUE")"
    ENV_FILE="$(mktemp)"
    "$PYTHON_BIN" -c 'import json,sys; print(json.dumps({"Variables": json.loads(sys.argv[1])}))' "$MERGED_ENV_JSON" > "$ENV_FILE"
    log "Updating Lambda environment variables (ensuring MONGODB_URI)"
    aws lambda update-function-configuration \
      --function-name "$LAMBDA_NAME" \
      --environment "file://$ENV_FILE" >/dev/null
    rm -f "$ENV_FILE"
    aws lambda wait function-updated --function-name "$LAMBDA_NAME"
  else
    log "Warning: neither MONGODB_URI nor MONGODB_CONNECTION_STRING is set on Lambda"
  fi
fi

log "Deployment complete"
echo "Lambda function: $LAMBDA_NAME"
echo "API Gateway URL: $API_URL"
echo "Health check: ${API_URL}/products?limit=1"
