// Get local IP so we can interface w/backend when previewing from other devices
// on the local network
import os from 'os';
const networkInterfaces = os.networkInterfaces();
const arr = networkInterfaces['en0']
const ip = arr[1].address

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
    runtimeConfig: {
        public: {
            baseURL: process.env.BASE_URL || `http://${ip}:4000`
        }
    },
    plugins: [
        // Enables page refresh on back navigation
        '@/plugins/windowRefresh.client.js',
    ],
    build: {
        postcss: {
            postcssOptions: {
                plugins: {
                    tailwindcss: {},
                    autoprefixer: {},
                }
            }
        }
    },

    css: [
        '@/assets/css/main.css'
    ]
})
