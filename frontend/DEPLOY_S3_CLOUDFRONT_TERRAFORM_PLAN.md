# Plan de Publicación Frontend en Amazon S3 + CloudFront (con Terraform)

## 1) Estado actual analizado

### Frontend
- Stack: React + Vite + TypeScript + Tailwind.
- El cliente HTTP usa `VITE_API_URL` en build-time:
  - `frontend/src/utils/env.ts`
  - `frontend/src/api/productsApi.ts`
- En local, Vite ya tiene proxy `/api` -> `VITE_API_URL` (`frontend/vite.config.ts`).

### Backend (ya en AWS)
- API en API Gateway HTTP + Lambda.
- Output disponible: `api_gateway_url` en Terraform dev.
- CORS actual en API Gateway: `allow_origins = ["*"]` (dev-friendly).

## 2) Objetivo de arquitectura

### Recomendado (más limpio)
- **CloudFront único dominio para frontend y API**:
  - Origen 1: S3 (frontend estático)
  - Origen 2: API Gateway (backend)
  - Behavior default (`/*`) -> S3
  - Behavior `/api/*` -> API Gateway
- Frontend consume API con ruta relativa (`/api`) en producción.
- Ventajas:
  - Evita problemas CORS en producción.
  - Un solo dominio público para front+back.
  - Seguridad y caché centralizadas.

## 3) Cambios Terraform propuestos

## 3.1 Nuevo módulo: `frontend_static_site`
Crear `infrastructure/terraform/modules/frontend_static_site/` con:
- `variables.tf`
- `main.tf`
- `outputs.tf`

Recursos del módulo:
1. `aws_s3_bucket` (bucket frontend)
2. `aws_s3_bucket_public_access_block` (todo bloqueado)
3. `aws_s3_bucket_versioning` (enabled)
4. `aws_s3_bucket_server_side_encryption_configuration`
5. `aws_cloudfront_origin_access_control` (OAC)
6. `aws_cloudfront_distribution`
   - Origen S3 (principal)
   - Origen API Gateway (secundario)
   - Behavior `/api/*` sin cache (o TTL muy bajo)
   - `viewer_protocol_policy = redirect-to-https`
   - `default_root_object = index.html`
   - Respuesta SPA para rutas React (`/products`, `/products/new`):
     - custom error response 403/404 -> `/index.html` con `200`
7. `aws_s3_bucket_policy` permitiendo lectura **solo** al CloudFront OAC.
8. (Opcional recomendado) Certificado ACM + Route53 para dominio custom.

## 3.2 Integración en `environments/dev`
Editar:
- `infrastructure/terraform/environments/dev/main.tf`
- `infrastructure/terraform/environments/dev/variables.tf`
- `infrastructure/terraform/environments/dev/outputs.tf`
- `infrastructure/terraform/environments/dev/terraform.tfvars(.example)`

Variables sugeridas:
- `frontend_enabled = true`
- `frontend_bucket_name`
- `frontend_aliases = []` (dominios)
- `frontend_acm_certificate_arn = null` (si no hay dominio)
- `frontend_api_origin_domain` (derivado de `api_gateway_url`)

Outputs sugeridos:
- `frontend_bucket_name`
- `frontend_cloudfront_domain_name`
- `frontend_cloudfront_distribution_id`
- `frontend_url`

## 3.3 Consideración sobre módulo S3 existente
- El módulo `modules/s3` actual está orientado al bucket de imágenes del backend y política para Lambda.
- **No reutilizar para hosting frontend** para evitar mezclar responsabilidades y permisos.

## 4) Conexión Frontend <-> Backend

## 4.1 Ajuste recomendado en frontend
Cambiar base URL en frontend para soportar producción con CloudFront:
- Producción: `VITE_API_URL=/api`
- Local: se mantiene `VITE_API_URL=http://localhost:8080` con proxy Vite.

Archivos a tocar:
- `frontend/.env` (para local puede seguir como está)
- `frontend/.env.example` (documentar modo prod con `/api`)
- `frontend/src/utils/env.ts` (sin cambios funcionales; ya soporta string)

## 4.2 CORS en API Gateway
Si usas behavior `/api/*` dentro del mismo dominio CloudFront:
- CORS puede restringirse en API Gateway a dominio CloudFront (recomendado para prod).

## 5) Flujo de despliegue propuesto

1. `terraform apply` infra (S3 + CloudFront + integración API).
2. Build frontend:
   ```bash
   cd frontend
   npm ci
   npm run build
   ```
3. Subida de estáticos a S3:
   ```bash
   aws s3 sync dist/ s3://<frontend-bucket> --delete
   ```
4. Invalidación CloudFront:
   ```bash
   aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
   ```

## 6) Script sugerido (siguiente fase)
Crear `frontend/deploy.sh` con pasos automáticos:
- leer outputs Terraform (`bucket`, `distribution_id`, `frontend_url`)
- `npm ci && npm run build`
- `aws s3 sync`
- `aws cloudfront create-invalidation`
- imprimir URL final

## 7) Checklist de validación

1. `frontend_url` responde `200` y carga `index.html`.
2. Navegación SPA funciona directo en rutas:
   - `/`
   - `/products`
   - `/products/new`
3. `GET /api/products` desde navegador responde sin error de CORS.
4. `POST /api/products` inserta correctamente.
5. Assets estáticos (`.js`, `.css`, imagen principal) cargan vía CloudFront.
6. Cache invalidation efectiva tras nuevo deploy.

## 8) Seguridad y operación

- Bucket S3 privado (sin website hosting público).
- Acceso solo por CloudFront OAC.
- TLS obligatorio (`redirect-to-https`).
- Versionado S3 activado.
- Separar ambiente dev/prod con buckets/distributions distintos.
- Para producción: dominio propio + ACM + políticas CORS restrictivas.

## 9) Resumen de ejecución recomendada

1. Implementar módulo Terraform `frontend_static_site`.
2. Integrarlo en `environments/dev`.
3. Ajustar frontend para consumir `/api` en producción.
4. Publicar build en S3 + invalidar CloudFront.
5. Verificar end-to-end front-back desde URL CloudFront.

## 10) Lista de tareas a ejecutar

1. Crear módulo Terraform `infrastructure/terraform/modules/frontend_static_site` (`main.tf`, `variables.tf`, `outputs.tf`).
2. Configurar en el módulo:
   - Bucket S3 privado + versionado + cifrado.
   - OAC de CloudFront.
   - Distribution CloudFront con behavior default `/*` a S3.
   - Behavior `/api/*` a API Gateway.
   - Reglas SPA (403/404 -> `/index.html` con 200).
3. Integrar módulo en `infrastructure/terraform/environments/dev/main.tf`.
4. Agregar variables en `environments/dev/variables.tf` y valores en `terraform.tfvars` / `terraform.tfvars.example`.
5. Exponer outputs en `environments/dev/outputs.tf`:
   - bucket frontend
   - domain/distribution CloudFront
   - URL final frontend
6. Ajustar frontend para producción:
   - `VITE_API_URL=/api`
   - mantener local con `VITE_API_URL=http://localhost:8080`.
7. Ejecutar infraestructura:
   ```bash
   cd infrastructure/terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```
8. Construir frontend:
   ```bash
   cd frontend
   npm ci
   npm run build
   ```
9. Publicar estáticos en S3:
   ```bash
   aws s3 sync dist/ s3://<frontend-bucket> --delete
   ```
10. Invalidar caché CloudFront:
    ```bash
    aws cloudfront create-invalidation --distribution-id <distribution-id> --paths "/*"
    ```
11. Probar frontend en la URL CloudFront.
12. Validar conexión backend desde frontend:
    - `GET /api/products`
    - `POST /api/products`
13. Revisar CORS y restringir `allow_origins` para producción (evitar `*`).
14. (Opcional) Configurar dominio custom + certificado ACM + Route53.
