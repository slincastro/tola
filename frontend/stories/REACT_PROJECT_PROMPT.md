# React Project Creation Prompt

## Project Request

Create a modern React application with the following specifications and architecture:

### Core Technology Stack
- **Framework**: React 18+ with TypeScript
- **Build Tool**: Vite (latest version)
- **Styling**: Tailwind CSS with PostCSS
- **Routing**: React Router v6
- **State Management**: React hooks (useState, useEffect, useMemo, useCallback)
- **API Integration**: Custom API layer with environment-based configuration
- **Icons**: Lucide React
- **Charts/Visualization**: Recharts
- **Development Tools**: ESLint, TypeScript strict mode

### Project Structure

```
project-name/
├── src/
│   ├── api/
│   │   ├── index.ts           # API factory with environment detection
│   │   ├── mockApi.ts          # Mock API implementation for development
│   │   ├── hybridApi.ts        # Hybrid API with fallback mechanisms
│   │   └── [domain]Api.ts      # Domain-specific API services
│   ├── components/
│   │   ├── Layout.tsx          # Main layout wrapper component
│   │   ├── Navigation.tsx      # Navigation component
│   │   ├── ui/                 # Reusable UI components
│   │   └── [feature]/          # Feature-specific components
│   ├── pages/
│   │   ├── Home.tsx            # Home page component
│   │   └── [feature]/          # Feature-specific pages
│   ├── types/
│   │   └── index.ts            # TypeScript type definitions
│   ├── utils/
│   │   └── [helpers].ts        # Utility functions
│   ├── hooks/
│   │   └── [custom-hooks].ts   # Custom React hooks
│   ├── App.tsx                 # Main app component with routing
│   ├── main.tsx                # Application entry point
│   └── index.css               # Global styles with Tailwind directives
├── public/
│   └── vite.svg                # Static assets
├── .env.example                 # Environment variables template
├── .env                         # Local environment variables
├── .eslintrc.cjs               # ESLint configuration
├── .gitignore
├── index.html                   # HTML entry point
├── package.json
├── postcss.config.js           # PostCSS configuration
├── tailwind.config.js          # Tailwind configuration
├── tsconfig.json               # TypeScript configuration
├── tsconfig.app.json           # App-specific TypeScript config
├── tsconfig.node.json          # Node-specific TypeScript config
└── vite.config.ts              # Vite configuration
```

### Configuration Files

#### package.json dependencies
```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.28.0",
    "lucide-react": "^0.454.0",
    "recharts": "^2.12.7",
    "date-fns": "^3.6.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.13.0",
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "autoprefixer": "^10.4.20",
    "eslint": "^9.13.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^0.4.14",
    "globals": "^15.11.0",
    "postcss": "^8.4.49",
    "tailwindcss": "^3.4.15",
    "typescript": "~5.6.2",
    "typescript-eslint": "^8.11.0",
    "vite": "^5.4.10"
  }
}
```

#### Vite Configuration
- React plugin with SWC for fast refresh
- Server configuration with port 5173
- Proxy configuration for API calls (if needed)
- Environment variable handling

#### Tailwind Configuration
```javascript
{
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: custom color palette,
        secondary: custom color palette
      }
    }
  }
}
```

#### TypeScript Configuration
- Strict mode enabled
- Module resolution: bundler
- JSX: react-jsx
- Target: ES2020
- Lib: ES2020, DOM, DOM.Iterable
- Path aliases for clean imports

### Key Features to Implement

1. **API Layer Architecture**
   - Environment-based API selection (mock, real, hybrid)
   - Centralized API configuration
   - Error handling and retry logic
   - Loading states management
   - Type-safe API responses

2. **Component Patterns**
   - Functional components with TypeScript
   - Custom hooks for data fetching
   - Loading, error, and empty states
   - Responsive design with Tailwind
   - Modular component structure

3. **Routing Structure**
   - Nested routes support
   - Protected routes (if authentication needed)
   - Route parameters and query strings
   - Navigation with active states
   - 404 page handling

4. **State Management**
   - Local component state with useState
   - Side effects with useEffect
   - Performance optimization with useMemo/useCallback
   - Context API for global state (if needed)

5. **UI/UX Features**
   - Responsive navigation with mobile support
   - Dark mode support (optional)
   - Loading skeletons
   - Error boundaries
   - Toast notifications
   - Data tables with sorting/filtering
   - Charts and visualizations

6. **Development Features**
   - Hot module replacement
   - Environment variables (.env)
   - ESLint for code quality
   - TypeScript for type safety
   - Mock data for development

### Environment Variables
```
VITE_API_URL=http://localhost:8080
VITE_API_MODE=mock|real|hybrid
VITE_ENABLE_MOCK=true
```

### Styling Guidelines
- Use Tailwind utility classes
- Custom CSS only when necessary
- Mobile-first responsive design
- Consistent spacing and typography
- Color scheme with primary/secondary colors
- Hover and focus states
- Smooth transitions and animations

### Code Quality Standards
- TypeScript strict mode
- ESLint rules enforcement
- Consistent file naming (PascalCase for components)
- Modular code organization
- Reusable components and utilities
- Comprehensive type definitions
- Clean and readable code

### Build and Deployment
- Development: `npm run dev`
- Build: `npm run build`
- Preview: `npm run preview`
- Lint: `npm run lint`
- Type check: `npm run type-check`

### Additional Considerations
- SEO optimization with proper meta tags
- Performance optimization (lazy loading, code splitting)
- Accessibility (ARIA labels, keyboard navigation)
- Browser compatibility
- Progressive enhancement
- Error tracking and logging

### Example Component Structure

```typescript
// Example of a typical component structure
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { LucideIcon } from 'lucide-react';
import { apiFactory } from '@/api';

interface ComponentProps {
  prop1: string;
  prop2?: number;
}

export function ComponentName({ prop1, prop2 = 0 }: ComponentProps) {
  const [data, setData] = useState<DataType | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const api = apiFactory();

  useEffect(() => {
    // Fetch data logic
  }, []);

  if (loading) return <LoadingComponent />;
  if (error) return <ErrorComponent error={error} />;
  if (!data) return <EmptyComponent />;

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Component content */}
    </div>
  );
}
```

Please create this React application with all the specified configurations, following the established patterns and best practices. The application should be production-ready, maintainable, and scalable.