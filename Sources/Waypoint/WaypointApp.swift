import SwiftUI
import SwiftData

@main
struct WaypointApp: App {
    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        // Tells SwiftData which model types to persist and hands the
        // resulting store to every view in the hierarchy automatically.
        .modelContainer(for: [Trip.self, ItineraryItem.self])
    }
}
