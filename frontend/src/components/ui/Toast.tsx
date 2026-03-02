import { X } from "lucide-react";
import type { ToastState } from "@/hooks/useToast";

export function Toast({ toast, onClose }: { toast: ToastState; onClose: () => void }) {
  if (!toast) return null;

  const style = toast.type === "success" ? "bg-primary-700" : "bg-red-600";

  return (
    <div className="fixed bottom-4 right-4 z-50 animate-rise">
      <div className={`flex items-center gap-3 rounded-xl px-4 py-3 text-sm text-white shadow-panel ${style}`} role="status">
        <span>{toast.message}</span>
        <button onClick={onClose} aria-label="Close toast" className="rounded-md bg-white/15 p-1 hover:bg-white/25">
          <X size={16} />
        </button>
      </div>
    </div>
  );
}
