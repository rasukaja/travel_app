# Waypoint — a trip planner for iPhone

Waypoint is a simple, local-only trip planner: create trips, then build a
timeline of flights, hotels, activities, and notes for each one, plus a
packing list, travel documents, and a route map. No account, no backend,
no API keys — everything stays on your device.

There are **two implementations** in this repo, because it turned out the
original plan (native Swift) needs a Mac to build and install, and that's
not available here:

| | [`webapp/`](webapp/) — **use this one** | [`Sources/`](Sources/) |
|---|---|---|
| Tech | React + TypeScript, installable as a PWA | SwiftUI + SwiftData |
| Install without a Mac | ✅ yes | ❌ no (Xcode is macOS-only) |
| Install on iPhone | Safari → Share → "Zum Home-Bildschirm" | Xcode → Run on device |
| Push notifications while closed | ❌ (iOS PWA limitation, see below) | ✅ |

Both cover the same feature set (itinerary timeline, packing list,
documents, route map). **The PWA is the one to install today.** The Swift
app is kept as-is in case a Mac (own, borrowed, or a rented cloud Mac like
MacinCloud) becomes available later — see its guide at
[docs/GUIDE.md](docs/GUIDE.md).

## Installing the PWA on your iPhone

1. This repo deploys `webapp/` to GitHub Pages automatically on every push
   (see `.github/workflows/pages.yml`). **One-time setup**: in the GitHub
   repo, go to **Settings → Pages** and set **Source: GitHub Actions** (only
   needed once — if it's already set, nothing to do).
2. Once the "Deploy Waypoint PWA to GitHub Pages" workflow has run
   successfully, the app is live at:
   `https://<your-github-username>.github.io/<repo-name>/`
   (check the workflow run, or Settings → Pages, for the exact URL).
3. Open that URL in **Safari on your iPhone** (must be Safari, not Chrome,
   for "Add to Home Screen" to install it as an app).
4. Tap the **Share** icon → **"Zum Home-Bildschirm"** ("Add to Home
   Screen") → **Add**.
5. Waypoint now has its own icon on your home screen and opens full-screen,
   like a native app. Data stays on your iPhone (IndexedDB) — nothing is
   sent to a server.

### If GitHub Pages isn't available (private repo on GitHub Free)

GitHub Pages for a *private* repo needs GitHub Pro or higher on a personal
account. If Settings → Pages doesn't offer "Source: GitHub Actions", either
upgrade, make the repo public (the code has no secrets — your actual trip
data only ever lives locally, never in the repo), or deploy the same build
elsewhere for free:

- **Netlify**: a `netlify.toml` is already in the repo root — "Add new site
  → Import an existing project", pick this repo, no further config needed.
- **Cloudflare Pages**: "Create a project → Connect to Git", pick this repo,
  set build command to `cd webapp && npm run build` and build output
  directory to `webapp/dist`.

Both are free, work with private repos, and need only a one-time account
connection — same install steps on the iPhone afterwards (Safari → Add to
Home Screen).

No Apple ID, no Xcode, no Apple Developer account, no Mac — the entire
build runs in GitHub Actions and the entire install happens in Safari.

### Known limitation: reminders

Real push notifications while the app is closed require a push server,
which this local-only app deliberately doesn't have. Instead, Waypoint
shows a "coming up" banner for items starting soon whenever you open the
app, and will fire a notification in the foreground if you grant
permission. If reliable background alerts turn out to matter more than
staying fully local/serverless, that's a good next feature to revisit.

## Repo layout

```
webapp/                    the PWA (React/TypeScript) — see webapp/README.md
Sources/Waypoint/          the native Swift app's source code
  WaypointApp.swift          app entry point
  Models/                    Trip, ItineraryItem, PackingItem, TravelDocument
  Services/                  NotificationManager, ItineraryImportParser
  Views/                     all the SwiftUI screens
Tests/WaypointTests/       Swift unit tests (model logic + the import parser)
project.yml                 optional XcodeGen project definition
docs/GUIDE.md                full step-by-step guide for the Swift app + Mac
.github/workflows/pages.yml  builds & deploys webapp/ to GitHub Pages
.github/workflows/ci.yml     builds & tests the Swift app on macOS runners
```

## If you get access to a Mac later

The native app in `Sources/` already has the same feature set and a CI
workflow that's green on macOS runners. `docs/GUIDE.md` walks through
opening it in Xcode and running it on a real iPhone from there — nothing
else needs to change.
