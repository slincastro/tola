# Tola Products Frontend

React + TypeScript + Vite + Tailwind frontend with:

- Routing (React Router v6)
- API mode switching (`mock`, `real`, `hybrid`)
- Products list with filters and cursor pagination
- Product creation form
- Recharts dashboard
- Error boundary and toast notifications

## Scripts

```bash
npm install
npm run dev
npm run lint
npm run type-check
npm run build
npm run preview
```

## Environment

Copy `.env.example` to `.env` and adjust:

```env
VITE_API_URL=http://localhost:8080
VITE_API_MODE=hybrid
VITE_ENABLE_MOCK=true
```

Production values are in `.env.production`:

```env
VITE_API_URL=/api
VITE_API_MODE=real
VITE_ENABLE_MOCK=false
```

## AWS Deploy (S3 + CloudFront)

1. Provision infrastructure first:

```bash
cd ../infrastructure/terraform/environments/dev
terraform init
terraform plan
terraform apply
```

2. Deploy frontend assets:

```bash
cd ../frontend
./deploy.sh
```

The script builds the app, uploads `dist/` to the Terraform output bucket, and creates a CloudFront invalidation.

## Structure

- `src/api`: API layer (`mockApi`, `productsApi`, `hybridApi`, `apiFactory`)
- `src/components`: layout, navigation, UI primitives, feature components
- `src/pages`: route pages
- `src/hooks`: custom hooks (`useProducts`, `useToast`)
- `src/types`: shared TypeScript models
