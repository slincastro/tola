import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react-swc";
export default defineConfig(function (_a) {
    var mode = _a.mode;
    var env = loadEnv(mode, new URL(".", import.meta.url).pathname, "");
    return {
        plugins: [react()],
        resolve: {
            alias: {
                "@": new URL("./src", import.meta.url).pathname
            }
        },
        server: {
            port: 5173,
            proxy: {
                "/api": {
                    target: env.VITE_API_URL || "http://localhost:8080",
                    changeOrigin: true,
                    rewrite: function (p) { return p.replace(/^\/api/, ""); }
                }
            }
        }
    };
});
