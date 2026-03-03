import { Outlet } from "react-router-dom";
import { Navigation } from "@/components/Navigation";
import sandIcon from "@/assets/min-icon.png";

export function Layout() {
  return (
    <div className="min-h-screen bg-[#E8E2D6] text-ink">
      <header className="border-b border-[#B89B5E]/40 bg-[#1F3A2E] text-[#E8E2D6]">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4">
          <div>
            <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight">
              <img src={sandIcon} alt="Sand icon" className="h-10 w-10 rounded-sm object-cover" />
              <span>Sumakpampa</span>
            </h1>
          </div>
        </div>
      </header>

      <div className="mx-auto grid max-w-7xl gap-4 px-4 py-6 sm:grid-cols-[220px_1fr]">
        <aside className="sm:sticky sm:top-4 sm:h-fit">
          
        </aside>

        <main className="space-y-4">
          <Outlet />
        </main>
      </div>

      <footer className="mt-8 border-t border-[#B89B5E]/40 bg-[#1F3A2E] text-[#E8E2D6]">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 text-sm">
          <p>Tola Platform - 2026</p>
          <p className="text-[#B89B5E]">Ven a vivir en el campo</p>
        </div>
      </footer>
    </div>
  );
}
