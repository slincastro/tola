export function toQueryString(params: Record<string, string | number | boolean | undefined>): string {
  const query = new URLSearchParams();

  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined) query.set(key, String(value));
  });

  const raw = query.toString();
  return raw ? `?${raw}` : "";
}
