import { Outlet } from "react-router-dom";
import { Navigation } from "@/components/Navigation";

export function Layout() {
  return (
    <div className="min-h-screen bg-cloud text-ink">
      <div className="mx-auto grid max-w-7xl gap-4 px-4 py-6 sm:grid-cols-[220px_1fr]">
        <aside className="sm:sticky sm:top-4 sm:h-fit">
          <div className="mb-3 rounded-2xl bg-gradient-to-r from-primary-700 via-primary-500 to-secondary-500 p-4 text-white shadow-panel">
            <h1 className="text-lg font-bold tracking-tight">Tola Console</h1>
            <p className="text-xs text-white/80">Product orchestration UI</p>
          </div>
          <Navigation />
        </aside>

        <main className="space-y-4">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
