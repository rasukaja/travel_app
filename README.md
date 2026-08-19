# Waypoint — a trip planner for iPhone

Waypoint is a simple, local-only trip planner: create trips, then build a
timeline of flights, hotels, activities, and notes for each one. No account,
no backend, no API keys — everything is stored on your iPhone with SwiftData.

Beyond the basics, Waypoint can also:

- **Import itineraries** — paste text or pick a PDF (boarding pass, hotel
  confirmation, itinerary email) and Waypoint suggests timeline entries for
  you to review and confirm before anything is saved.
- **Show the route** — every itinerary item with a location, in order, with
  one tap to open the whole trip as a route in Google Maps.
- **Track a packing list** per trip.
- **Attach photos/PDFs** (tickets, confirmations, passport scans) to any
  itinerary item.
- **Remind you** with a local notification an hour before an item starts.

This repo is set up as a **first iOS coding project**. If you're new to this:

**Start here → [docs/GUIDE.md](docs/GUIDE.md)** — a full walkthrough from
"I have a Mac and nothing else" to "my app is running on my iPhone", plus
what comes after (App Store, next features).

## What's in this repo

```
Sources/Waypoint/          the app's Swift source code
  WaypointApp.swift          app entry point
  Models/                    Trip, ItineraryItem, PackingItem, TravelDocument
  Services/                  NotificationManager, ItineraryImportParser
  Views/                     all the SwiftUI screens
Tests/WaypointTests/       unit tests (model logic + the import parser)
project.yml                 optional XcodeGen project definition
docs/GUIDE.md                the full step-by-step guide
```

There's no `.xcodeproj` committed here — you'll create it locally in Xcode
(see the guide, Part 4). That's normal: project files are regenerated per
machine/Xcode version and don't belong in git for a solo project like this.

## Quick start (once you've read Part 1–4 of the guide)

1. Create a new iOS App project in Xcode named **Waypoint**, interface
   **SwiftUI**, storage **SwiftData**, minimum deployment **iOS 17**.
2. Delete the template's `ContentView.swift` and the default `Item.swift`
   (if SwiftData was pre-selected, Xcode may generate a placeholder model).
3. Drag the `Models`, `Services`, and `Views` folders and `WaypointApp.swift`
   from this repo's `Sources/Waypoint/` into your Xcode project navigator
   (check "Copy items if needed").
4. Build and run (`⌘R`) in the Simulator.

Full details, screenshots-in-words, and troubleshooting are in the guide.
