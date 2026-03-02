#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONT_DIR="$ROOT_DIR/frontend"
TF_DIR="$ROOT_DIR/infrastructure/terraform/environments/dev"

SKIP_BUILD="${SKIP_BUILD:-false}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd aws
require_cmd terraform
require_cmd npm

if [[ "$SKIP_BUILD" != "true" ]]; then
  echo "[frontend] Installing dependencies"
  npm --prefix "$FRONT_DIR" ci

  echo "[frontend] Building production bundle"
  npm --prefix "$FRONT_DIR" run build
fi

BUCKET_NAME="$(terraform -chdir="$TF_DIR" output -raw frontend_bucket_name)"
DISTRIBUTION_ID="$(terraform -chdir="$TF_DIR" output -raw frontend_cloudfront_distribution_id)"
FRONTEND_URL="$(terraform -chdir="$TF_DIR" output -raw frontend_url)"

if [[ -z "$BUCKET_NAME" || "$BUCKET_NAME" == "null" ]]; then
  echo "frontend_bucket_name output is empty. Run terraform apply first." >&2
  exit 1
fi

if [[ -z "$DISTRIBUTION_ID" || "$DISTRIBUTION_ID" == "null" ]]; then
  echo "frontend_cloudfront_distribution_id output is empty. Run terraform apply first." >&2
  exit 1
fi

echo "[frontend] Syncing dist/ to s3://$BUCKET_NAME"
aws s3 sync "$FRONT_DIR/dist/" "s3://$BUCKET_NAME" --delete

echo "[frontend] Creating CloudFront invalidation"
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*" >/dev/null

echo "[frontend] Deployment complete"
echo "Frontend URL: $FRONTEND_URL"
