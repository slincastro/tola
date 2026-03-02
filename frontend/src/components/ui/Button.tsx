import type { ButtonHTMLAttributes, ReactNode } from "react";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  variant?: "primary" | "ghost";
};

export function Button({ children, variant = "primary", className = "", ...props }: Props) {
  const base = "inline-flex items-center justify-center rounded-xl px-4 py-2 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-50";
  const styles =
    variant === "primary"
      ? "bg-primary-500 text-white hover:bg-primary-700"
      : "bg-white/70 text-ink ring-1 ring-slate-200 hover:bg-slate-50";

  return (
    <button {...props} className={`${base} ${styles} ${className}`.trim()}>
      {children}
    </button>
  );
}
