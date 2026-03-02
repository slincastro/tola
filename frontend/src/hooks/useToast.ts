import { useCallback, useState } from "react";

export type ToastState = {
  type: "success" | "error";
  message: string;
} | null;

export function useToast() {
  const [toast, setToast] = useState<ToastState>(null);

  const showToast = useCallback((type: "success" | "error", message: string) => {
    setToast({ type, message });
    window.setTimeout(() => setToast(null), 2800);
  }, []);

  const clearToast = useCallback(() => setToast(null), []);

  return { toast, showToast, clearToast };
}
