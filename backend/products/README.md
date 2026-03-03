# Products API

API de productos construida con FastAPI, desplegada en AWS Lambda y expuesta por API Gateway.

## Endpoints

- `POST /products`
- `GET /products`

App entrypoint:
- `backend/products/app.py`

## Deploy a AWS

Script de despliegue:
- `backend/products/deploy.sh`

El script hace:
1. Empaqueta la app (`backend/products`) para Lambda con `Mangum`.
   - Instala dependencias como wheels Linux (`manylinux2014_x86_64`, Python 3.10) para compatibilidad con Lambda.
2. Ejecuta `terraform init/plan/apply` en `infrastructure/terraform/environments/dev`.
3. Obtiene `lambda_function_name` y `api_gateway_url` desde Terraform outputs.
4. Actualiza el código de Lambda con el zip generado.
5. Asegura variable `MONGODB_URI` (usa fallback de `MONGODB_CONNECTION_STRING`).
6. Imprime URL final del API.

## Prerrequisitos

- AWS CLI autenticado (`aws configure`)
- Terraform instalado
- Python 3 + pip
- `zip`
- Credenciales AWS con permisos para Lambda/API Gateway/IAM/EC2/ECS según tu infraestructura

## Comando principal

Desde la raíz del repo:

```bash
./backend/products/deploy.sh
```

## Variables opcionales del script

- `AUTO_APPROVE=true` aplica Terraform sin confirmación.
- `RUN_TERRAFORM=false` omite Terraform y solo empaqueta/actualiza Lambda.
- `RUN_LAMBDA_CODE_UPDATE=false` ejecuta Terraform pero no actualiza código de Lambda.
- `PYTHON_BIN` y `PIP_BIN` para cambiar binarios (`python3`, `pip3`, etc.).

Ejemplos:

```bash
AUTO_APPROVE=true ./backend/products/deploy.sh
RUN_TERRAFORM=false ./backend/products/deploy.sh
RUN_LAMBDA_CODE_UPDATE=false ./backend/products/deploy.sh
```

## Verificación rápida

Al finalizar el deploy, el script muestra:
- `Lambda function: ...`
- `API Gateway URL: ...`
- `Health check: <api_url>/products?limit=1`

Prueba manual:

```bash
curl -s "<API_GATEWAY_URL>/products?limit=1"
```

## Desarrollo local

```bash
cd backend/products
uvicorn app:app --reload --port 8000
```



python3 backend/products/product_loader/load_products.py \
  --api-base-url https://454pqm0o6c.execute-api.us-east-1.amazonaws.com
