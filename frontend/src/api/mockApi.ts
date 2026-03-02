import { subDays } from "date-fns";
import type { ApiClient, CreateProductPayload, Product, ProductFilters, ProductListResponse } from "@/types";

const now = new Date();

let products: Product[] = [
  {
    id: "mock-1",
    mid: "merchant-001",
    name: "Terreno urbano",
    description: "Lote con acceso a servicios y vias principales.",
    surface: { value: 450, unit: "m2" },
    services: ["water", "electricity"],
    price: { amount: 120000, currency: "USD", negotiable: true },
    sector: { name: "Centro", city: "Quito", province: "Pichincha", country: "Ecuador" },
    location: {
      geometry: {
        type: "Polygon",
        coordinates: [[[-78.4921, -0.1807], [-78.4915, -0.1807], [-78.4915, -0.1812], [-78.4921, -0.1807]]]
      },
      centroid: { type: "Point", coordinates: [-78.4918, -0.1809] }
    },
    media: { photos: [] },
    createdAt: subDays(now, 4).toISOString(),
    updatedAt: subDays(now, 1).toISOString()
  },
  {
    id: "mock-2",
    mid: "merchant-002",
    name: "Casa campestre",
    description: "Casa amplia con jardin.",
    surface: { value: 300, unit: "m2" },
    services: ["water", "internet"],
    price: { amount: 98000, currency: "USD", negotiable: false },
    sector: { name: "Cumbaya", city: "Quito", province: "Pichincha", country: "Ecuador" },
    location: {
      geometry: {
        type: "Polygon",
        coordinates: [[[-78.44, -0.2], [-78.43, -0.2], [-78.43, -0.21], [-78.44, -0.2]]]
      },
      centroid: { type: "Point", coordinates: [-78.435, -0.205] }
    },
    media: { photos: [] },
    createdAt: subDays(now, 8).toISOString(),
    updatedAt: subDays(now, 2).toISOString()
  }
];

function applyFilters(items: Product[], filters: ProductFilters): Product[] {
  return items.filter((p) => {
    if (filters.sector && p.sector.name !== filters.sector) return false;
    if (filters.min_price !== undefined && p.price.amount < filters.min_price) return false;
    if (filters.max_price !== undefined && p.price.amount > filters.max_price) return false;
    if (filters.negotiable !== undefined && p.price.negotiable !== filters.negotiable) return false;
    return true;
  });
}

export const mockApi: ApiClient = {
  async getProducts(filters = {}): Promise<ProductListResponse> {
    const limit = filters.limit ?? 20;
    const sorted = [...products].sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
    const filtered = applyFilters(sorted, filters);
    const start = filters.cursor ? filtered.findIndex((i) => i.id === filters.cursor) + 1 : 0;
    const slice = filtered.slice(start, start + limit);
    const nextCursor = filtered[start + limit]?.id ?? null;

    return {
      items: slice,
      page: { limit, nextCursor }
    };
  },

  async createProduct(payload: CreateProductPayload): Promise<{ id: string; createdAt: string; updatedAt: string }> {
    const timestamp = new Date().toISOString();
    const id = `mock-${crypto.randomUUID()}`;

    products = [
      {
        ...payload,
        id,
        createdAt: timestamp,
        updatedAt: timestamp
      },
      ...products
    ];

    return { id, createdAt: timestamp, updatedAt: timestamp };
  }
};
