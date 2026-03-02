import { useMemo } from "react";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { Card } from "@/components/ui/Card";
import { useProducts } from "@/hooks/useProducts";
import sumakpampaMain from "@/assets/sumakpampa-main.png";

export function HomePage() {
  const { items, loading, error } = useProducts({ limit: 50 });

  const data = useMemo(() => {
    const bySector = new Map<string, number>();
    (items || []).forEach((product) => {
      const sectorName = product?.sector?.name || "Unknown";
      bySector.set(sectorName, (bySector.get(sectorName) || 0) + 1);
    });

    return Array.from(bySector.entries()).map(([sector, count]) => ({ sector, count }));
  }, [items]);

  return (
    <div className="space-y-4">
      <Card>
        <div className="overflow-hidden rounded-xl ">
          <img src={sumakpampaMain} alt="Sumakpampa main"  />
        </div>
      </Card>
    </div>
  );
}
