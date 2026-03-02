type QueryValue = string | number | boolean | undefined | null;

export function toQueryString<T extends object>(params: T): string {
  const query = new URLSearchParams();

  Object.entries(params as Record<string, QueryValue>).forEach(([key, value]) => {
    if (value !== undefined && value !== null) query.set(key, String(value));
  });

  const raw = query.toString();
  return raw ? `?${raw}` : "";
}
