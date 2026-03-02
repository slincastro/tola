import type { ApiClient, CreateProductPayload, ProductFilters, ProductListResponse } from "@/types";

export function createHybridApi(realApi: ApiClient, fallbackApi: ApiClient): ApiClient {
  const withFallback = async <T>(operation: () => Promise<T>, fallback: () => Promise<T>): Promise<T> => {
    try {
      return await operation();
    } catch (error) {
      console.warn("Hybrid API fallback triggered", error);
      return fallback();
    }
  };

  return {
    getProducts(filters?: ProductFilters): Promise<ProductListResponse> {
      return withFallback(() => realApi.getProducts(filters), () => fallbackApi.getProducts(filters));
    },
    createProduct(payload: CreateProductPayload): Promise<{ id: string; createdAt: string; updatedAt: string }> {
      return withFallback(() => realApi.createProduct(payload), () => fallbackApi.createProduct(payload));
    }
  };
}
