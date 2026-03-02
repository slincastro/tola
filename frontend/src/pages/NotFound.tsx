import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";

export function NotFoundPage() {
  return (
    <div className="rounded-2xl bg-white p-8 text-center shadow-panel">
      <h2 className="text-2xl font-bold text-ink">404</h2>
      <p className="mt-2 text-slate-600">The page you requested does not exist.</p>
      <Link to="/" className="mt-4 inline-block">
        <Button>Back home</Button>
      </Link>
    </div>
  );
}
