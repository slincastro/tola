import { Button } from "@/components/ui/Button";
import { Skeleton } from "@/components/ui/Skeleton";
import { useProducts } from "@/hooks/useProducts";

const currencyFormatter = new Intl.NumberFormat("es-EC", {
  style: "currency",
  currency: "USD",
  minimumFractionDigits: 2
});

const areaFormatter = new Intl.NumberFormat("es-EC", {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2
});

export function ProductsPage() {
  const { items, loading, error, nextCursor, loadMore } = useProducts({ limit: 12 });

  return (
    <section className="space-y-6">
      <header className="rounded-3xl border border-[#B89B5E]/50 bg-gradient-to-r from-[#1F3A2E] via-[#2E5B47] to-[#1F3A2E] px-6 py-8 text-[#E8E2D6] shadow-panel">
        <p className="text-sm uppercase tracking-[0.2em] text-[#D7C28C]">Catalogo</p>
        <h2 className="mt-2 text-3xl font-semibold">Terrenos Disponibles</h2>
        <p className="mt-2 max-w-2xl text-sm text-[#E8E2D6]/90">
          
        </p>
      </header>

      {loading && items.length === 0 ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <Skeleton className="h-48 rounded-2xl" />
          <Skeleton className="h-48 rounded-2xl" />
          <Skeleton className="h-48 rounded-2xl" />
        </div>
      ) : null}

      {error ? <p className="rounded-2xl border border-red-200 bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}

      {!loading && !error && items.length === 0 ? (
        <p className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-600">No hay productos para mostrar.</p>
      ) : null}

      {items.length > 0 ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {items.map((item) => (
            <article key={item.id} className="rounded-2xl border border-[#CBB07A]/60 bg-white p-5 shadow-panel">
              <h3 className="text-lg font-semibold text-[#1F3A2E]">{item.name}</h3>
              <p className="mt-3 line-clamp-4 text-sm leading-relaxed text-slate-600">{item.description}</p>
              <dl className="mt-5 space-y-3 text-sm">
                <div className="flex items-center justify-between rounded-xl bg-[#F6F1E5] px-3 py-2">
                  <dt className="font-medium text-slate-600">Superficie</dt>
                  <dd className="font-semibold text-[#1F3A2E]">
                    {areaFormatter.format(item.surface.value)} {item.surface.unit}
                  </dd>
                </div>
                <div className="flex items-center justify-between rounded-xl bg-[#EAF2ED] px-3 py-2">
                  <dt className="font-medium text-slate-600">Costo</dt>
                  <dd className="font-semibold text-[#1F3A2E]">{currencyFormatter.format(item.price.amount)}</dd>
                </div>
              </dl>
            </article>
          ))}
        </div>
      ) : null}

      <div className="flex justify-end">
        <Button variant="ghost" onClick={loadMore} disabled={!nextCursor || loading}>
          {loading && items.length > 0 ? "Cargando..." : nextCursor ? "Ver mas productos" : "No hay mas resultados"}
        </Button>
      </div>
    </section>
  );
}
