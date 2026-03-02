import type { ReactNode } from "react";

type Props = { title?: string; subtitle?: string; children: ReactNode; actions?: ReactNode };

export function Card({ title, subtitle, children, actions }: Props) {
  return (
    <section className="rounded-2xl bg-white p-5 shadow-panel ring-1 ring-slate-100">
      {(title || subtitle || actions) && (
        <header className="mb-4 flex items-start justify-between gap-4">
          <div>
            {title && <h3 className="text-lg font-semibold text-ink">{title}</h3>}
            {subtitle && <p className="mt-1 text-sm text-slate-500">{subtitle}</p>}
          </div>
          {actions}
        </header>
      )}
      {children}
    </section>
  );
}
