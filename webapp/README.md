# Waypoint (PWA)

The web/PWA version of Waypoint — a local-only trip planner: trips, an
itinerary timeline (flights/hotels/activities/notes), a packing list,
travel documents (photos), and a route map. No account, no backend —
everything is stored on-device via IndexedDB.

This exists alongside the native SwiftUI app in `../Sources` because it
can be built and installed on an iPhone entirely from a Windows (or Linux)
machine — no Mac/Xcode required. See the root [README](../README.md) for
the full picture and installation instructions.

## Development

```bash
npm install
npm run dev       # http://localhost:5173
npm run build     # production build -> dist/
npm run preview   # serve the production build locally
```

## Regenerating app icons

`scripts/generate-icons.mjs` renders `public/*.png` (PWA + Apple touch
icons) from an inline SVG using headless Chromium via `playwright-core` —
no external image tooling needed:

```bash
node scripts/generate-icons.mjs
```

## Smoke test

`scripts/smoke-test.mjs` drives the built app in headless Chromium
(create a trip, add an itinerary item, packing item, open the map tab) and
fails if any console/page error occurs:

```bash
npm run build && npx vite preview --port 4173 --strictPort &
node scripts/smoke-test.mjs
```
