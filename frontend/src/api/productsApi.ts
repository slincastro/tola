import type { ApiClient, CreateProductPayload, ProductFilters, ProductListResponse } from "@/types";
import { toQueryString } from "@/utils/query";

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

      return (await response.json()) as ProductListResponse;
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
