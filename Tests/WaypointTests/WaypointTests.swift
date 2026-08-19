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

    func testPackingListSortsUncheckedFirstThenAlphabetically() {
        let trip = Trip(name: "Test Trip", destination: "Testville", startDate: .now, endDate: .now)
        let sunscreen = PackingItem(title: "Sunscreen", isChecked: false, trip: trip)
        let passport = PackingItem(title: "Passport", isChecked: false, trip: trip)
        let socks = PackingItem(title: "Socks", isChecked: true, trip: trip)
        trip.packingItems = [sunscreen, passport, socks]

        XCTAssertEqual(trip.sortedPackingItems.map(\.title), ["Passport", "Sunscreen", "Socks"])
    }

    func testImportParserFindsDateAndGuessesFlightType() {
        let text = "Flight AA100 departs JFK Airport on March 5, 2027 at 10:30 AM"
        let drafts = ItineraryImportParser.parse(text)

        XCTAssertEqual(drafts.count, 1)
        XCTAssertEqual(drafts.first?.type, .flight)
        XCTAssertNotNil(drafts.first?.date)
        XCTAssertTrue(drafts.first?.isSelected ?? false)
    }

    func testImportParserGuessesHotelType() {
        let text = "Hotel check-in: Park Hyatt Tokyo on June 1, 2027"
        let drafts = ItineraryImportParser.parse(text)

        XCTAssertEqual(drafts.first?.type, .hotel)
    }

    func testImportParserSurfacesRelevantLinesWithoutDatesAsUnselected() {
        let text = "Hotel reservation confirmed, no date in this line"
        let drafts = ItineraryImportParser.parse(text)

        XCTAssertEqual(drafts.count, 1)
        XCTAssertNil(drafts.first?.date)
        XCTAssertFalse(drafts.first?.isSelected ?? true)
    }

    func testImportParserIgnoresIrrelevantTextWithoutDates() {
        let text = "Just some unrelated notes with no dates or travel keywords here"
        let drafts = ItineraryImportParser.parse(text)

        XCTAssertTrue(drafts.isEmpty)
    }
}
