import { useMemo, useState } from "react";
import { ArrowUpDown } from "lucide-react";
import type { Product } from "@/types";
import { Button } from "@/components/ui/Button";

type SortKey = "name" | "price" | "sector";

type Props = {
  items: Product[];
  onLoadMore: () => void;
  canLoadMore: boolean;
  loadingMore: boolean;
};

export function ProductTable({ items, onLoadMore, canLoadMore, loadingMore }: Props) {
  const [sortKey, setSortKey] = useState<SortKey>("name");
  const [asc, setAsc] = useState(true);

  const sortedItems = useMemo(() => {
    const buffer = [...items];

    buffer.sort((a, b) => {
      let left: string | number = "";
      let right: string | number = "";

      if (sortKey === "name") {
        left = a.name.toLowerCase();
        right = b.name.toLowerCase();
      } else if (sortKey === "price") {
        left = a.price.amount;
        right = b.price.amount;
      } else {
        left = a.sector.name.toLowerCase();
        right = b.sector.name.toLowerCase();
      }

      if (left < right) return asc ? -1 : 1;
      if (left > right) return asc ? 1 : -1;
      return 0;
    });

    return buffer;
  }, [items, sortKey, asc]);

  const toggleSort = (next: SortKey) => {
    if (next === sortKey) {
      setAsc((current) => !current);
      return;
    }

    setSortKey(next);
    setAsc(true);
  };

  return (
    <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white">
      <div className="overflow-x-auto">
        <table className="min-w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-600">
            <tr>
              <th className="px-4 py-3">
                <button className="inline-flex items-center gap-1" onClick={() => toggleSort("name")}>
                  Name <ArrowUpDown size={14} />
                </button>
              </th>
              <th className="px-4 py-3">Merchant</th>
              <th className="px-4 py-3">
                <button className="inline-flex items-center gap-1" onClick={() => toggleSort("sector")}>
                  Sector <ArrowUpDown size={14} />
                </button>
              </th>
              <th className="px-4 py-3">
                <button className="inline-flex items-center gap-1" onClick={() => toggleSort("price")}>
                  Price <ArrowUpDown size={14} />
                </button>
              </th>
            </tr>
          </thead>
          <tbody>
            {sortedItems.map((item) => (
              <tr key={item.id} className="border-t border-slate-100">
                <td className="px-4 py-3 font-medium text-ink">{item.name}</td>
                <td className="px-4 py-3 text-slate-600">{item.mid}</td>
                <td className="px-4 py-3 text-slate-600">{item.sector.name}</td>
                <td className="px-4 py-3 text-slate-700">${item.price.amount.toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="flex justify-end border-t border-slate-100 p-3">
        <Button variant="ghost" onClick={onLoadMore} disabled={!canLoadMore || loadingMore}>
          {loadingMore ? "Loading..." : canLoadMore ? "Load more" : "No more results"}
        </Button>
      </div>
    </div>
  );
}
