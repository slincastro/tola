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

## Structure

- `src/api`: API layer (`mockApi`, `productsApi`, `hybridApi`, `apiFactory`)
- `src/components`: layout, navigation, UI primitives, feature components
- `src/pages`: route pages
- `src/hooks`: custom hooks (`useProducts`, `useToast`)
- `src/types`: shared TypeScript models
