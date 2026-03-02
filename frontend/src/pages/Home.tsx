import { useMemo } from "react";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { Card } from "@/components/ui/Card";
import { useProducts } from "@/hooks/useProducts";

export function HomePage() {
  const { items, loading, error } = useProducts({ limit: 50 });

  const data = useMemo(() => {
    const bySector = new Map<string, number>();
    items.forEach((product) => {
      bySector.set(product.sector.name, (bySector.get(product.sector.name) || 0) + 1);
    });

    return Array.from(bySector.entries()).map(([sector, count]) => ({ sector, count }));
  }, [items]);

  return (
    <div className="space-y-4">
      <Card title="Overview" subtitle="Current catalog pulse">
        <div className="grid gap-3 sm:grid-cols-3">
          <div className="rounded-xl bg-primary-50 p-4">
            <p className="text-xs uppercase tracking-wide text-primary-700">Products</p>
            <p className="mt-2 text-3xl font-bold text-primary-900">{items.length}</p>
          </div>
          <div className="rounded-xl bg-secondary-50 p-4">
            <p className="text-xs uppercase tracking-wide text-secondary-700">Sectors</p>
            <p className="mt-2 text-3xl font-bold text-secondary-900">{new Set(items.map((i) => i.sector.name)).size}</p>
          </div>
          <div className="rounded-xl bg-slate-100 p-4">
            <p className="text-xs uppercase tracking-wide text-slate-600">Negotiable</p>
            <p className="mt-2 text-3xl font-bold text-slate-900">{items.filter((i) => i.price.negotiable).length}</p>
          </div>
        </div>
      </Card>

      <Card title="Products by sector" subtitle="Live data from selected API mode">
        {loading ? <p className="text-sm text-slate-500">Loading chart...</p> : null}
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        {!loading && !error && data.length === 0 ? <p className="text-sm text-slate-500">No data yet.</p> : null}

        {data.length > 0 && (
          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data}>
                <CartesianGrid strokeDasharray="3 3" stroke="#dbe4e8" />
                <XAxis dataKey="sector" stroke="#55636b" />
                <YAxis stroke="#55636b" />
                <Tooltip />
                <Bar dataKey="count" fill="#1f9f76" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </Card>
    </div>
  );
}
