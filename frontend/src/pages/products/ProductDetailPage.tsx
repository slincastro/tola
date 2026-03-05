import { useEffect, useMemo, useState } from "react";
import { Link, useLocation, useParams } from "react-router-dom";
import { apiFactory } from "@/api";
import type { Product } from "@/types";

const currencyFormatter = new Intl.NumberFormat("es-EC", {
  style: "currency",
  currency: "USD",
  minimumFractionDigits: 2
});

const areaFormatter = new Intl.NumberFormat("es-EC", {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2
});

type ProductState = {
  product?: Product;
};

async function fetchProductById(productId: string): Promise<Product | null> {
  const api = apiFactory();
  let cursor: string | undefined;

  for (let i = 0; i < 30; i += 1) {
    const response = await api.getProducts({ limit: 100, cursor });
    const found = response.items.find((item) => item.id === productId);

    if (found) return found;
    if (!response.page.nextCursor) break;

    cursor = response.page.nextCursor;
  }

  return null;
}

export function ProductDetailPage() {
  const { productId = "" } = useParams();
  const location = useLocation();
  const state = (location.state || {}) as ProductState;
  const [product, setProduct] = useState<Product | null>(state.product ?? null);
  const [loading, setLoading] = useState(!state.product);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!productId || state.product) return;

    let cancelled = false;

    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const result = await fetchProductById(productId);
        if (cancelled) return;
        if (!result) {
          setError("No se encontro el producto solicitado.");
          return;
        }
        setProduct(result);
      } catch (err) {
        if (cancelled) return;
        setError(err instanceof Error ? err.message : "Error inesperado al cargar producto.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    void load();

    return () => {
      cancelled = true;
    };
  }, [productId, state.product]);

  const centroidText = useMemo(() => {
    if (!product?.location?.centroid?.coordinates || product.location.centroid.coordinates.length < 2) return "N/A";
    const [lng, lat] = product.location.centroid.coordinates;
    return `${lat}, ${lng}`;
  }, [product]);

  if (loading) {
    return <p className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-600">Cargando detalle...</p>;
  }

  if (error || !product) {
    return (
      <div className="space-y-4">
        <p className="rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">{error || "Producto no disponible."}</p>
        <Link to="/products" className="text-sm font-semibold text-[#1F3A2E] underline">
          Volver a terrenos
        </Link>
      </div>
    );
  }

  return (
    <section className="space-y-6">
      <header className="rounded-3xl border border-[#B89B5E]/50 bg-gradient-to-r from-[#1F3A2E] via-[#2E5B47] to-[#1F3A2E] px-6 py-8 text-[#E8E2D6] shadow-panel">
        <p className="text-sm uppercase tracking-[0.2em] text-[#D7C28C]">Detalle de terreno</p>
        <h2 className="mt-2 text-3xl font-semibold">{product.name}</h2>
        <p className="mt-2 max-w-3xl text-sm text-[#E8E2D6]/90">{product.description}</p>
      </header>

      <div className="grid gap-4 lg:grid-cols-2">
        <article className="rounded-2xl border border-[#CBB07A]/60 bg-white p-5 shadow-panel">
          <h3 className="text-base font-semibold text-[#1F3A2E]">Datos principales</h3>
          <dl className="mt-4 space-y-3 text-sm">
            <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
              <dt className="text-slate-600">Superficie</dt>
              <dd className="font-semibold text-[#1F3A2E]">
                {areaFormatter.format(product.surface.value)} {product.surface.unit}
              </dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#EAF2ED] px-3 py-2">
              <dt className="text-slate-600">Costo</dt>
              <dd className="font-semibold text-[#1F3A2E]">{currencyFormatter.format(product.price.amount)}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
              <dt className="text-slate-600">Moneda</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.price.currency}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#EAF2ED] px-3 py-2">
              <dt className="text-slate-600">Negociable</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.price.negotiable ? "Si" : "No"}</dd>
            </div>
          </dl>
        </article>

        <article className="rounded-2xl border border-[#CBB07A]/60 bg-white p-5 shadow-panel">
          <h3 className="text-base font-semibold text-[#1F3A2E]">Ubicacion y sector</h3>
          <dl className="mt-4 space-y-3 text-sm">
            <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
              <dt className="text-slate-600">Sector</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.sector.name}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#EAF2ED] px-3 py-2">
              <dt className="text-slate-600">Ciudad</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.sector.city}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
              <dt className="text-slate-600">Provincia</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.sector.province}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#EAF2ED] px-3 py-2">
              <dt className="text-slate-600">Pais</dt>
              <dd className="font-semibold text-[#1F3A2E]">{product.sector.country}</dd>
            </div>
            <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
              <dt className="text-slate-600">Centroide (lat,lng)</dt>
              <dd className="font-semibold text-[#1F3A2E]">{centroidText}</dd>
            </div>
          </dl>
        </article>
      </div>

      <article className="rounded-2xl border border-[#CBB07A]/60 bg-white p-5 shadow-panel">
        <h3 className="text-base font-semibold text-[#1F3A2E]">Caracteristicas</h3>
        {product.services.length > 0 ? (
          <ul className="mt-4 grid gap-2 md:grid-cols-2">
            {product.services.map((service) => (
              <li key={service} className="rounded-xl bg-[#F6F1E5] px-3 py-2 text-sm text-slate-700">
                {service}
              </li>
            ))}
          </ul>
        ) : (
          <p className="mt-3 text-sm text-slate-600">Sin caracteristicas registradas.</p>
        )}
      </article>


      <div>
        <Link to="/products" className="text-sm font-semibold text-[#1F3A2E] underline">
          Volver a la lista
        </Link>
      </div>
    </section>
  );
}
