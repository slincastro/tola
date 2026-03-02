/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#effaf6",
          100: "#d6f2e6",
          500: "#1f9f76",
          700: "#187b5b",
          900: "#0f4f3a"
        },
        secondary: {
          50: "#fef4e8",
          100: "#fde4c8",
          500: "#e5902f",
          700: "#b56f22",
          900: "#6b4010"
        },
        ink: "#182226",
        cloud: "#f7faf9"
      },
      boxShadow: {
        panel: "0 14px 35px -20px rgba(24, 34, 38, 0.35)"
      },
      keyframes: {
        rise: {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        }
      },
      animation: {
        rise: "rise 400ms ease-out"
      }
    }
  },
  plugins: []
};
