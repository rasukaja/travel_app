import Foundation
import SwiftData

/// A single trip, e.g. "Summer in Italy". Holds the trip's basic info
/// and owns a list of ItineraryItems (flights, hotels, activities, ...).
@Model
final class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var emoji: String

    /// Deleting a trip also deletes every itinerary item that belongs to it.
    @Relationship(deleteRule: .cascade, inverse: \ItineraryItem.trip)
    var items: [ItineraryItem] = []

    /// Deleting a trip also deletes its packing checklist.
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.trip)
    var packingItems: [PackingItem] = []

    init(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        emoji: String = "✈️"
    ) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.emoji = emoji
    }

    /// The trip's itinerary items in chronological order.
    var sortedItems: [ItineraryItem] {
        items.sorted { $0.date < $1.date }
    }

    /// Packing checklist with unchecked items first, then alphabetically.
    var sortedPackingItems: [PackingItem] {
        packingItems.sorted {
            if $0.isChecked != $1.isChecked { return !$0.isChecked }
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
}
