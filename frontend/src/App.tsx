import { lazy, Suspense } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import { Layout } from "@/components/Layout";
import { Toast } from "@/components/ui/Toast";
import { useToast } from "@/hooks/useToast";

const HomePage = lazy(() => import("@/pages/Home").then((m) => ({ default: m.HomePage })));
const ProductsPage = lazy(() => import("@/pages/products/ProductsPage").then((m) => ({ default: m.ProductsPage })));
const ProductDetailPage = lazy(() => import("@/pages/products/ProductDetailPage").then((m) => ({ default: m.ProductDetailPage })));
const NewProductPage = lazy(() => import("@/pages/products/NewProductPage").then((m) => ({ default: m.NewProductPage })));
const NotFoundPage = lazy(() => import("@/pages/NotFound").then((m) => ({ default: m.NotFoundPage })));

export default function App() {
  const { toast, showToast, clearToast } = useToast();

  return (
    <>
      <Suspense fallback={<div className="p-6 text-sm text-slate-500">Loading...</div>}>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<HomePage />} />
            <Route path="/products" element={<ProductsPage />} />
            <Route path="/products/:productId" element={<ProductDetailPage />} />
            <Route path="/products/new" element={<NewProductPage onCreated={(message) => showToast("success", message)} />} />
            <Route path="/home" element={<Navigate to="/" replace />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
      </Suspense>

      <Toast toast={toast} onClose={clearToast} />
    </>
  );
}
