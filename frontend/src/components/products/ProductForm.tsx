import { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { apiFactory } from "@/api";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import type { CreateProductPayload } from "@/types";

type Props = {
  onCreated: (message: string) => void;
};

const defaultPayload: CreateProductPayload = {
  mid: "merchant_001",
  name: "",
  description: "",
  surface: { value: 100, unit: "m2" },
  services: ["water"],
  price: { amount: 0, currency: "USD", negotiable: false },
  sector: { name: "", city: "", province: "", country: "Ecuador" },
  location: {
    geometry: {
      type: "Polygon",
      coordinates: [[[-78.4921, -0.1807], [-78.4915, -0.1807], [-78.4915, -0.1812], [-78.4921, -0.1807]]]
    },
    centroid: { type: "Point", coordinates: [-78.4918, -0.1809] }
  },
  media: { photos: [] }
};

export function ProductForm({ onCreated }: Props) {
  const api = useMemo(() => apiFactory(), []);
  const navigate = useNavigate();
  const [form, setForm] = useState<CreateProductPayload>(defaultPayload);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const update = <K extends keyof CreateProductPayload>(key: K, value: CreateProductPayload[K]) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setSaving(true);
    setError(null);

    try {
      await api.createProduct(form);
      onCreated("Product created successfully");
      navigate("/products");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create product");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Card title="Create product" subtitle="Post /products with typed validation">
      <form className="grid gap-3 sm:grid-cols-2" onSubmit={submit}>
        <Input
          label="Name"
          value={form.name}
          onChange={(e) => update("name", e.target.value)}
          required
          aria-label="Product name"
        />
        <Input
          label="Merchant ID"
          value={form.mid}
          onChange={(e) => update("mid", e.target.value)}
          required
          aria-label="Merchant id"
        />
        <Input
          label="Sector"
          value={form.sector.name}
          onChange={(e) => update("sector", { ...form.sector, name: e.target.value })}
          required
        />
        <Input
          label="Price (USD)"
          type="number"
          min={0}
          value={String(form.price.amount)}
          onChange={(e) => update("price", { ...form.price, amount: Number(e.target.value || 0) })}
          required
        />
        <label className="sm:col-span-2 flex flex-col gap-2 text-sm font-medium text-slate-700">
          Description
          <textarea
            className="min-h-24 rounded-xl border border-slate-200 px-3 py-2 text-sm outline-none focus:border-primary-500 focus:ring-2 focus:ring-primary-100"
            value={form.description}
            onChange={(e) => update("description", e.target.value)}
            required
          />
        </label>

        {error && <p className="sm:col-span-2 text-sm text-red-600">{error}</p>}

        <div className="sm:col-span-2 flex justify-end gap-2">
          <Button type="button" variant="ghost" onClick={() => navigate("/products")}>Cancel</Button>
          <Button type="submit" disabled={saving}>{saving ? "Saving..." : "Save product"}</Button>
        </div>
      </form>
    </Card>
  );
}
