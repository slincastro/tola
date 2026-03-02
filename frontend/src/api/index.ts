import type { ApiClient } from "@/types";
import { env } from "@/utils/env";
import { createProductsApi } from "@/api/productsApi";
import { mockApi } from "@/api/mockApi";
import { createHybridApi } from "@/api/hybridApi";

let singleton: ApiClient | null = null;

export function apiFactory(): ApiClient {
  if (singleton) return singleton;

  const realApi = createProductsApi(env.apiUrl);

  if (env.apiMode === "real") {
    singleton = realApi;
  } else if (env.apiMode === "hybrid") {
    singleton = createHybridApi(realApi, mockApi);
  } else {
    singleton = mockApi;
  }

  return singleton;
}
