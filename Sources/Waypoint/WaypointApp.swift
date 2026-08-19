import SwiftUI
import SwiftData

@main
struct WaypointApp: App {
    var body: some Scene {
        WindowGroup {
            TripListView()
                .task {
                    // Ask once, early, so reminder toggles work right away.
                    // Declining is fine — reminders are just skipped later.
                    await NotificationManager.shared.requestAuthorizationIfNeeded()
                }
        }
        // Tells SwiftData which model types to persist and hands the
        // resulting store to every view in the hierarchy automatically.
        .modelContainer(for: [Trip.self, ItineraryItem.self, PackingItem.self, TravelDocument.self])
    }
}
