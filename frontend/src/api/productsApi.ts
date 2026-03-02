import type { ApiClient, CreateProductPayload, ProductFilters, ProductListResponse } from "@/types";
import { toQueryString } from "@/utils/query";

function normalizeProductListResponse(payload: unknown): ProductListResponse {
  if (!payload || typeof payload !== "object") {
    return { items: [], page: { limit: 20, nextCursor: null } };
  }

  const data = payload as Partial<ProductListResponse> & { page?: { limit?: number; nextCursor?: string | null } };

  return {
    items: Array.isArray(data.items) ? data.items : [],
    page: {
      limit: typeof data.page?.limit === "number" ? data.page.limit : 20,
      nextCursor:
        data.page?.nextCursor === null || typeof data.page?.nextCursor === "string" ? data.page.nextCursor : null
    }
  };
}

export function createProductsApi(baseUrl: string): ApiClient {
  return {
    async getProducts(filters: ProductFilters = {}): Promise<ProductListResponse> {
      const query = toQueryString(filters);
      const response = await fetch(`${baseUrl.replace(/\/$/, "")}/products${query}`, {
        method: "GET",
        headers: { "Content-Type": "application/json" }
      });

      if (!response.ok) {
        throw new Error(`Failed to load products (${response.status})`);
      }

      const payload = (await response.json()) as unknown;
      return normalizeProductListResponse(payload);
    },

    async createProduct(payload: CreateProductPayload): Promise<{ id: string; createdAt: string; updatedAt: string }> {
      const response = await fetch(`${baseUrl.replace(/\/$/, "")}/products`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });

      if (!response.ok) {
        const detail = await response.text();
        throw new Error(`Failed to create product (${response.status}): ${detail}`);
      }

      return (await response.json()) as { id: string; createdAt: string; updatedAt: string };
    }
  };
}
