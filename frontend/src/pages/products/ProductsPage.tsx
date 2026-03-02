import { useCallback } from "react";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Skeleton } from "@/components/ui/Skeleton";
import { ProductTable } from "@/components/products/ProductTable";
import { useProducts } from "@/hooks/useProducts";

export function ProductsPage() {
  const { items, loading, error, nextCursor, filters, setFilters, loadMore } = useProducts({ limit: 20 });

  const onSectorChange = useCallback(
    (value: string) => {
      setFilters((prev) => ({ ...prev, sector: value || undefined }));
    },
    [setFilters]
  );

  return (
    <div className="space-y-4">
      <Card title="Products" subtitle="Filter, sort and paginate your catalog">
        <div className="grid gap-3 sm:grid-cols-3">
          <Input label="Sector" value={filters.sector || ""} onChange={(e) => onSectorChange(e.target.value)} />
          <Input
            label="Min price"
            type="number"
            min={0}
            value={filters.min_price ?? ""}
            onChange={(e) => setFilters((p) => ({ ...p, min_price: e.target.value ? Number(e.target.value) : undefined }))}
          />
          <Input
            label="Max price"
            type="number"
            min={0}
            value={filters.max_price ?? ""}
            onChange={(e) => setFilters((p) => ({ ...p, max_price: e.target.value ? Number(e.target.value) : undefined }))}
          />
        </div>
      </Card>

      {loading && items.length === 0 ? (
        <div className="space-y-2">
          <Skeleton className="h-10" />
          <Skeleton className="h-10" />
          <Skeleton className="h-10" />
        </div>
      ) : null}

      {error ? <p className="rounded-xl bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}

      {!loading && !error && items.length === 0 ? (
        <p className="rounded-xl bg-white p-4 text-sm text-slate-600 shadow-panel">No products match the current filters.</p>
      ) : null}

      {items.length > 0 ? (
        <ProductTable items={items} onLoadMore={loadMore} canLoadMore={Boolean(nextCursor)} loadingMore={loading} />
      ) : null}
    </div>
  );
}
