import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import laravel from "laravel-vite-plugin";

export default defineConfig({
    server: {
        host: true,
        port: parseInt(process.env.VITE_PORT || "5173"),
        hmr: {
            host:
                process.env.APP_URL?.replace(/^https?:\/\//, "") || "localhost",
        },
    },
    plugins: [
        vue(),
        laravel({
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
    ],
});
