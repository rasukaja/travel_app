import Foundation
import SwiftData

/// The kind of thing an itinerary entry represents. Add new cases here
/// when you want to support more entry types later.
enum ItineraryItemType: String, Codable, CaseIterable, Identifiable {
    case flight
    case hotel
    case activity
    case transport
    case note

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flight: return "Flight"
        case .hotel: return "Hotel"
        case .activity: return "Activity"
        case .transport: return "Transport"
        case .note: return "Note"
        }
    }

    /// SF Symbol name used to represent this type in the UI.
    var symbolName: String {
        switch self {
        case .flight: return "airplane"
        case .hotel: return "bed.double.fill"
        case .activity: return "figure.walk"
        case .transport: return "car.fill"
        case .note: return "note.text"
        }
    }
}

/// One entry on a trip's timeline, e.g. "Flight to Tokyo" or "Check in at hotel".
@Model
final class ItineraryItem {
    var title: String
    var type: ItineraryItemType
    var date: Date
    var location: String
    var notes: String
    var trip: Trip?

    init(
        title: String,
        type: ItineraryItemType = .activity,
        date: Date = .now,
        location: String = "",
        notes: String = "",
        trip: Trip? = nil
    ) {
        self.title = title
        self.type = type
        self.date = date
        self.location = location
        self.notes = notes
        self.trip = trip
    }
}
