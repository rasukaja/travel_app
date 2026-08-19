import Foundation
import SwiftData

/// One entry on a trip's packing checklist, e.g. "Passport" or "Sunscreen".
@Model
final class PackingItem {
    var title: String
    var isChecked: Bool
    var trip: Trip?

    init(title: String, isChecked: Bool = false, trip: Trip? = nil) {
        self.title = title
        self.isChecked = isChecked
        self.trip = trip
    }
}
