# Building Waypoint: your first iPhone app, start to finish

This is a complete path from zero to an app running on your own iPhone, and
then (if you want) published on the App Store. It assumes this is your
first coding project, so it over-explains rather than under-explains —
skip anything that already feels obvious.

The app we're building, **Waypoint**, is a trip planner: you create trips,
and add flights/hotels/activities/notes to each one, shown as a timeline.
Everything is stored locally on your phone — no server, no accounts, no
API keys — which means Parts 1–7 get you to a genuinely working app with
nothing but a Mac and free tools.

---

## Part 0 — How the pieces fit together

A few terms you'll see everywhere, defined once up front:

- **Swift** — the programming language you'll write.
- **SwiftUI** — Apple's toolkit for building the *screens* (buttons, lists,
  forms) declaratively: you describe what the UI should look like for a
  given piece of data, and SwiftUI keeps it updated automatically.
- **SwiftData** — Apple's toolkit for *storing* data on the device (your
  trips and itinerary items) so it's still there next time you open the app.
- **Xcode** — the app (an IDE) you write, run, and debug all of this in.
  It also builds the finished app and can submit it to the App Store.
- **Simulator** — a virtual iPhone that runs inside Xcode on your Mac, so
  you can test without a physical device.

You do not need to know any of this in depth before starting — you'll pick
it up by building.

---

## Part 1 — Prerequisites

1. **A Mac.** iOS development requires Xcode, which only runs on macOS.
   (This repo's code was written in a Linux environment and can't be
   compiled or run there — you'll do that part on your own Mac.)
2. **A free Apple ID.** You already have one if you use an iPhone. This is
   enough to build and run your own app on your own iPhone for free — no
   paid account needed yet.
3. **Xcode**, installed free from the Mac App Store. It's a large download
   (10–15+ GB) — start it early. Search "Xcode", install, then open it
   once and let it finish installing additional components.
4. **This repo, cloned to your Mac.** You're likely reading this on the
   `claude/iphone-travel-app-dev-a8n2le` branch already — on your Mac:
   ```
   git clone <your repo URL>
   cd travel_app
   git checkout claude/iphone-travel-app-dev-a8n2le
   ```

That's it — no paid developer account, no API keys, nothing else installed.

---

## Part 2 — Just enough Swift/SwiftUI to be dangerous

You don't need a separate course before starting; you'll learn fastest by
running Waypoint and then changing small things in it. Two free resources
worth keeping open in a tab as you go:

- Apple's own [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui) —
  official, interactive, builds a small app step by step.
- [Hacking with Swift — 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui) —
  free, extremely popular with beginners, short daily lessons.

The handful of concepts that show up constantly in this codebase, briefly:

- `struct` — most Swift types (including every SwiftUI screen) are structs:
  simple value types. `class` is used for SwiftData models (`Trip`,
  `ItineraryItem`) because SwiftData needs reference semantics.
- `var` / `let` — `var` is a variable you can change, `let` is a constant.
- A SwiftUI **View** is a struct with a `body` property describing what to
  draw. `TripListView`, `TripDetailView`, etc. are all views.
- `@State` — a piece of data a view owns and can change, that redraws the
  view when it changes (e.g. `isShowingAddTrip` in `TripListView`).
- `@Model` — marks a class as a SwiftData model that gets saved to disk
  (`Trip`, `ItineraryItem`).
- `@Query` — fetches model objects from SwiftData and keeps the view in
  sync automatically as data changes.
- `@Environment(\.modelContext)` — how a view gets access to SwiftData to
  insert/delete things.

You'll see all of these in context in Part 5.

---

## Part 3 — What we're actually building (and what we're not, yet)

**MVP scope** (this is what's already written for you in `Sources/Waypoint`):

- A list of trips (name, destination, dates, an emoji).
- Tapping a trip opens its itinerary: a timeline of items, each with a
  type (flight / hotel / activity / transport / note), title, date & time,
  location, and notes.
- Add, edit, delete trips and itinerary items. Swipe-to-delete on both
  lists.
- Everything persists automatically between launches — no save button,
  no network.

**Deliberately out of scope for v1**, so you get something working fast:

- No real flight/hotel search or booking (that needs a backend + API keys
  and is a much bigger project — see "Where to go next" below).
- No photos, maps, or push notifications yet.
- No accounts or syncing between devices (SwiftData is local-only unless
  you later turn on iCloud sync, which is a small config change).

Building the small thing first and *actually finishing it* is the single
best habit for a first project — it's tempting to design the "real" app
with logins and live flight data before anything runs at all. Resist that.

---

## Part 4 — Create the Xcode project

You have two options. If this is genuinely your first project, use
**Option A** — it's the standard, guided path and teaches you what Xcode's
project wizard actually does.

### Option A — Xcode's own "New Project" wizard (recommended)

1. Open Xcode → **File → New → Project…**
2. Choose **iOS → App**, click Next.
3. Fill in:
   - **Product Name:** `Waypoint`
   - **Team:** your Apple ID (add it via Xcode → Settings → Accounts if
     it's not listed yet)
   - **Organization Identifier:** anything reverse-DNS-shaped, e.g.
     `com.yourname`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** SwiftData
4. Save it *outside* this repo's folder for now (e.g. your Desktop) —
   you'll bring the real source files in next, and it's easier to see
   what you're doing with a clean temporary location. Uncheck "Create Git
   repository" (this repo already is one).
5. Xcode creates a project with a template `ContentView.swift` and an
   `Item.swift` SwiftData model. Delete both — they're just a starting
   placeholder ("File → Delete", choose "Move to Trash").
6. In Finder, drag this repo's `Sources/Waypoint/Models`,
   `Sources/Waypoint/Views` folders and `Sources/Waypoint/WaypointApp.swift`
   into Xcode's project navigator (left sidebar), inside the `Waypoint`
   group. When prompted, check **"Copy items if needed"** and make sure
   the **Waypoint** target is checked.
7. Delete whatever leftover `WaypointApp.swift` the template created (you
   now have your own, copied in).
8. Move the whole `Waypoint.xcodeproj` folder into this repo's root
   (`travel_app/`), replacing the temporary location. This keeps your
   Xcode project alongside the source under version control going forward
   (the project file itself stays out of git per `.gitignore` — see the
   note in `README.md` for why that's normal).

### Option B — XcodeGen (faster once you're comfortable with the terminal)

This repo includes a `project.yml`. If you install
[XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`),
you can generate the `.xcodeproj` directly from the already-in-place source
files instead of doing the drag-and-drop in Option A:

```
cd travel_app
xcodegen generate
open Waypoint.xcodeproj
```

Treat `project.yml` as a starting point — you may need to tweak the
bundle identifier or signing team inside Xcode afterward (Signing &
Capabilities tab on the Waypoint target).

Either way, you should end up with a `Waypoint.xcodeproj` you can open,
build, and run.

---

## Part 5 — Understanding the code you now have

Take a slow pass through these files in this order — each builds on the
last:

1. **`Models/Trip.swift`** and **`Models/ItineraryItem.swift`** — the data.
   `@Model` is the only SwiftData-specific thing here; everything else is
   plain Swift. Note the `@Relationship(deleteRule: .cascade, ...)` on
   `Trip.items` — that's what makes deleting a trip also delete its
   itinerary items.
2. **`WaypointApp.swift`** — the entry point. `.modelContainer(for:)` is
   the one line that turns SwiftData on for the whole app.
3. **`Views/TripListView.swift`** — the home screen. Look at `@Query` (it
   fetches all trips, sorted by start date, and keeps the list live) and
   `NavigationLink(value:)` / `.navigationDestination(for:)` (how tapping
   a trip navigates to its detail screen).
4. **`Views/TripDetailView.swift`** and **`Views/ItineraryRow.swift`** —
   the timeline for one trip.
5. **`Views/AddEditTripView.swift`** and
   **`Views/AddEditItineraryItemView.swift`** — the forms, presented as
   sheets (`.sheet(isPresented:)` / `.sheet(item:)`). Notice
   `AddEditItineraryItemView` is reused for both "add" and "edit" by
   making `item` optional.

A good first exercise: change `Trip`'s default emoji, or add a `notes`
field to `Trip` (mirror how `ItineraryItem.notes` works) and show it on
`TripDetailView`. That round-trip — model → view → form — is the whole
pattern the rest of the app is built from.

---

## Part 6 — Run it

1. In Xcode's toolbar, pick a Simulator (e.g. "iPhone 15") from the device
   dropdown next to the Play button.
2. Press **⌘R** (or the Play button). First build takes a minute or two.
3. You should see "My Trips" with an empty state. Tap **+**, create a
   trip, tap into it, add a few itinerary items. Force-quit and reopen the
   app in the simulator (or stop/re-run) — your data should still be there.

If it doesn't build, read the error in the left-hand issue navigator
(⌘5) — Swift's error messages usually point at the exact line and reason.

### Running on your actual iPhone

1. Plug your iPhone into your Mac (or pair it wirelessly: Xcode → Window →
   Devices and Simulators).
2. Select your iPhone in the device dropdown instead of a simulator, press
   ⌘R.
3. First time only: on the iPhone, go to **Settings → General → VPN &
   Device Management** and trust your developer certificate.
4. With a free Apple ID ("Personal Team"), the app stays installed and
   runs for **7 days**, then needs re-installing from Xcode. A paid Apple
   Developer Program membership ($99/year, Part 10) removes that limit and
   is only needed when you want longer-lived installs, TestFlight, or the
   App Store.

---

## Part 7 — Version control habits

This repo is already a git repo on the right branch. As you make changes:

```
git status                 # see what changed
git add -A
git commit -m "Add trip notes field"
git push
```

Good habits for a solo project:
- Commit whenever something works, before starting the next change — small
  commits make it easy to undo a bad idea (`git checkout -- <file>` or
  `git revert`).
- Keep `.xcuserdata`/`DerivedData`/build junk out of git — the `.gitignore`
  here already handles this.
- Write commit messages that say *why*, not just *what* ("Add cascade
  delete so removing a trip clears its items" beats "update Trip.swift").

---

## Part 8 — Testing and growing the app safely

`Tests/WaypointTests/WaypointTests.swift` has two example tests. To wire
them up: when creating the project in Part 4, check **"Include Tests"** (or
add a target later via File → New → Target → "Unit Testing Bundle" named
`WaypointTests`), then add that file to it the same way you added the
source files. Run tests with **⌘U**.

Testing matters more as the app grows, but even for a small app, a couple
of tests around your data model (like the sorting test here) catch a
surprising number of "wait, why is my list in the wrong order" bugs early.

When adding a feature, a steady loop:
1. Change one model/view at a time.
2. Run (⌘R), poke at it in the simulator.
3. Commit.
4. Repeat.

Avoid changing five files at once on a first project — if something breaks,
you want to know which change did it.

---

## Part 9 — Polish

Once the core flows work, these make it feel like a real app:

- **App icon** — Xcode's template `Assets.xcassets` has an `AppIcon` slot.
  Design a 1024×1024 image (any image editor, or a generator like
  [appicon.co](https://appicon.co)), drag it in. I can also mock up icon
  concepts with the `design` skill if you want a starting visual.
- **Accent color** — `Assets.xcassets → AccentColor` controls button/tint
  color app-wide (used by `ItineraryRow`'s icons via `.tint`).
- **Dark mode** — SwiftUI handles this automatically for standard colors;
  just check both appearances (Simulator → Features → Toggle Appearance).
- **Empty states & accessibility** — already partly done via
  `ContentUnavailableView`; also check that text scales with Dynamic Type
  and that tappable icons have clear labels (`Label` already does this for
  you in most spots here).
- **App name & launch screen** — set via target settings (General tab) and
  `INFOPLIST_KEY_UILaunchScreen_Generation`.

---

## Part 10 — Shipping it (TestFlight and the App Store)

You only need this once you want the app on a device other than your own,
or want it to survive past the 7-day free-signing limit long-term.

1. **Enroll in the Apple Developer Program** — $99/year, at
   [developer.apple.com/programs](https://developer.apple.com/programs/enroll/).
2. **Create an App Store Connect record** — appstoreconnect.apple.com →
   My Apps → **+** → New App. Pick a bundle ID matching your Xcode
   project's, a name, primary language, category.
3. **Archive the build** — in Xcode, select "Any iOS Device" (not a
   simulator) as the destination, then **Product → Archive**. The
   Organizer window opens when it's done.
4. **Upload** — in the Organizer, "Distribute App" → App Store Connect →
   Upload. Xcode handles signing if your Team is set correctly.
5. **TestFlight** — once processed (10–60 min), the build appears under
   TestFlight in App Store Connect. You can install it on your own devices
   immediately, or invite up to 10,000 testers by email/link — this is a
   great way to get it on a phone without submitting for review at all,
   if that's all you need.
6. **App Store review** — when ready for the public store: fill in
   screenshots, description, privacy policy URL (required — even a simple
   one stating you collect no data, since Waypoint is fully local), age
   rating, then submit the build for review. Apple's review typically
   takes 1–3 days. Common rejection reasons for small first apps: missing
   privacy policy, crashes on launch, incomplete metadata, placeholder
   content — none of which should be an issue for a finished, tested
   Waypoint.

---

## Where to go next

Once the MVP works end to end, natural next features, roughly in order of
difficulty:

1. **Trip notes / cover photo** — extend `Trip`, add an image picker
   (`PhotosPicker`).
2. **Packing list** — a new `@Model` (`PackingItem`) with a checkbox,
   owned by `Trip`, same pattern as `ItineraryItem`.
3. **Maps** — show itinerary item locations on a `MapKit` map; needs
   geocoding the free-text `location` field or switching it to a proper
   place picker.
4. **Notifications** — local notifications reminding you of an upcoming
   flight/hotel check-in (`UserNotifications`, no backend needed).
5. **iCloud sync across your devices** — small SwiftData config change
   (`ModelConfiguration(cloudKitDatabase:)`) plus enabling the iCloud
   capability.
6. **Real flight/hotel search** — this is the point where you'd need a
   backend or a travel API. If you want to explore that later, flight
   search (e.g. via Kiwi.com) is something I can help wire up as a
   separate, bigger milestone — it changes the architecture (network
   layer, API keys, loading/error states) enough that it's worth doing as
   its own project phase rather than bolting onto the MVP.

Come back anytime with "let's add X to Waypoint" and I can help design and
write that feature the same way this one was built.
