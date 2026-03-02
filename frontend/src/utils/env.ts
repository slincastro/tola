export type ApiMode = "mock" | "real" | "hybrid";

export const env = {
  apiUrl: import.meta.env.VITE_API_URL || "http://localhost:8080",
  apiMode: (import.meta.env.VITE_API_MODE || "mock") as ApiMode,
  enableMock: String(import.meta.env.VITE_ENABLE_MOCK || "true") === "true"
};
