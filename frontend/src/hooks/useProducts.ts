import { useCallback, useEffect, useMemo, useState } from "react";
import { apiFactory } from "@/api";
import type { Product, ProductFilters } from "@/types";

export function useProducts(initialFilters: ProductFilters = {}) {
  const api = useMemo(() => apiFactory(), []);
  const [items, setItems] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [filters, setFilters] = useState<ProductFilters>(initialFilters);

  const load = useCallback(
    async (reset = true) => {
      setLoading(true);
      setError(null);

      try {
        const response = await api.getProducts({ ...filters, cursor: reset ? undefined : nextCursor || undefined });

        setItems((prev) => (reset ? response.items : [...prev, ...response.items]));
        setNextCursor(response.page.nextCursor);
      } catch (err) {
        const message = err instanceof Error ? err.message : "Unexpected error";
        setError(message);
      } finally {
        setLoading(false);
      }
    },
    [api, filters, nextCursor]
  );

  useEffect(() => {
    void load(true);
  }, [filters.sector, filters.min_price, filters.max_price, filters.negotiable]);

  const loadMore = useCallback(async () => {
    if (!nextCursor || loading) return;
    await load(false);
  }, [nextCursor, loading, load]);

  return {
    items,
    loading,
    error,
    nextCursor,
    filters,
    setFilters,
    refresh: () => load(true),
    loadMore
  };
}
