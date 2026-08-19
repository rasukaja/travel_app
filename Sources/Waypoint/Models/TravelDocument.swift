import Foundation
import SwiftData

/// What kind of file a TravelDocument holds, so the UI can pick a sensible
/// icon/preview.
enum TravelDocumentKind: String, Codable {
    case photo
    case pdf
    case other
}

/// A photo or PDF attached to one itinerary item — a boarding pass, hotel
/// confirmation, passport scan, etc. The raw bytes are stored via SwiftData's
/// external storage so large photos/PDFs don't bloat the main database file.
@Model
final class TravelDocument {
    var filename: String
    var kind: TravelDocumentKind
    @Attribute(.externalStorage) var data: Data
    var createdAt: Date
    var item: ItineraryItem?

    init(
        filename: String,
        kind: TravelDocumentKind,
        data: Data,
        createdAt: Date = .now,
        item: ItineraryItem? = nil
    ) {
        self.filename = filename
        self.kind = kind
        self.data = data
        self.createdAt = createdAt
        self.item = item
    }
}
