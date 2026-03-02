import { Home, Package, PlusCircle } from "lucide-react";
import { NavLink } from "react-router-dom";

const links = [
  { to: "/", label: "Home", icon: Home },
  { to: "/products", label: "Products", icon: Package },
  { to: "/products/new", label: "Add Product", icon: PlusCircle }
];

export function Navigation() {
  return (
    <nav className="rounded-2xl bg-white p-2 shadow-panel ring-1 ring-slate-100">
      <ul className="grid grid-cols-3 gap-2 sm:flex sm:flex-col">
        {links.map((link) => (
          <li key={link.to}>
            <NavLink
              to={link.to}
              className={({ isActive }) =>
                [
                  "flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-medium transition",
                  isActive ? "bg-primary-50 text-primary-700" : "text-slate-600 hover:bg-slate-50"
                ].join(" ")
              }
            >
              <link.icon size={16} />
              <span>{link.label}</span>
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  );
}
