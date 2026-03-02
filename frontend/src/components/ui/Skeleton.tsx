export function Skeleton({ className = "h-6" }: { className?: string }) {
  return <div className={`animate-pulse rounded-lg bg-slate-200/70 ${className}`.trim()} aria-hidden="true" />;
}
