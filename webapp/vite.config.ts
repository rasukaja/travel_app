import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

// Relative base so the built app works from any sub-path (e.g. GitHub
// Pages project sites at https://<user>.github.io/<repo>/), and HashRouter
// is used for the same reason (no server-side rewrite rules needed).
export default defineConfig({
  base: './',
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'apple-touch-icon.png'],
      manifest: {
        id: '/',
        name: 'Waypoint – Reiseplaner',
        short_name: 'Waypoint',
        description: 'Reisen planen: Zeitstrahl, Packliste, Dokumente und Karte – alles lokal auf deinem Gerät.',
        theme_color: '#0a56ff',
        background_color: '#f2f2f7',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '.',
        scope: '.',
        lang: 'de',
        icons: [
          { src: 'pwa-192x192.png', sizes: '192x192', type: 'image/png' },
          { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png' },
          { src: 'maskable-icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png,ico}'],
        // Map tiles come from OpenStreetMap over the network; cache them
        // so a trip's map stays usable offline once viewed.
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/[a-z]\.tile\.openstreetmap\.org\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'osm-tiles',
              expiration: { maxEntries: 300, maxAgeSeconds: 30 * 24 * 60 * 60 },
            },
          },
        ],
      },
      devOptions: { enabled: false },
    }),
  ],
});
