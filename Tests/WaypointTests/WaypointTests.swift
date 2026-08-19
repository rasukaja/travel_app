import XCTest
@testable import Waypoint

// This file goes in a "Unit Testing Bundle" target named WaypointTests
// (Xcode creates one for you if you check "Include Tests" when creating
// the project — see docs/GUIDE.md, Part 8).
final class WaypointTests: XCTestCase {
    func testTripSortedItemsOrdersChronologically() {
        let trip = Trip(
            name: "Test Trip",
            destination: "Testville",
            startDate: .now,
            endDate: .now.addingTimeInterval(86400)
        )

        let later = ItineraryItem(title: "Later", date: Date(timeIntervalSince1970: 2000), trip: trip)
        let earlier = ItineraryItem(title: "Earlier", date: Date(timeIntervalSince1970: 1000), trip: trip)
        trip.items = [later, earlier]

        XCTAssertEqual(trip.sortedItems.map(\.title), ["Earlier", "Later"])
    }

    func testItineraryItemTypeDisplayNames() {
        XCTAssertEqual(ItineraryItemType.flight.displayName, "Flight")
        XCTAssertEqual(ItineraryItemType.hotel.symbolName, "bed.double.fill")
    }
}
