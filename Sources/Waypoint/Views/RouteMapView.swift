import SwiftUI

/// Shows the trip's stops (every itinerary item that has a location) in
/// chronological order, and opens them as a route in Google Maps.
///
/// This deliberately deep-links into Google Maps (app if installed,
/// otherwise the website) rather than embedding Google's map SDK — that
/// would need an API key and a billing-enabled Google Cloud project, which
/// doesn't fit an app with no accounts, no keys, and nothing but local
/// storage. The Google Maps "directions" URL scheme needs neither: it just
/// takes place names/addresses as plain text.
struct RouteMapView: View {
    let trip: Trip

    private var stops: [ItineraryItem] {
        trip.sortedItems.filter { !$0.location.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        Group {
            if stops.count < 2 {
                ContentUnavailableView(
                    "Not Enough Stops Yet",
                    systemImage: "map",
                    description: Text("Add a location to at least two itinerary items to see a route.")
                )
            } else {
                List {
                    Section {
                        Link(destination: routeURL) {
                            Label("Open Full Route in Google Maps", systemImage: "map.fill")
                        }
                    } footer: {
                        Text("Opens all \(stops.count) stops as a route, in order, in the Google Maps app or website.")
                    }

                    Section("Stops") {
                        ForEach(Array(stops.enumerated()), id: \.element.id) { index, item in
                            HStack(alignment: .top) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(.tint, in: Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title).font(.body.weight(.medium))
                                    Text(item.location)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(item.date, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }

                                Spacer()

                                Link(destination: singleStopURL(for: item)) {
                                    Image(systemName: "arrow.up.right.square")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Route")
    }

    /// https://developers.google.com/maps/documentation/urls/get-started#directions-action
    private var routeURL: URL {
        var components = URLComponents(string: "https://www.google.com/maps/dir/")!
        var items = [URLQueryItem(name: "api", value: "1")]
        items.append(URLQueryItem(name: "travelmode", value: "driving"))
        items.append(URLQueryItem(name: "origin", value: stops.first!.location))
        items.append(URLQueryItem(name: "destination", value: stops.last!.location))
        if stops.count > 2 {
            let middle = stops.dropFirst().dropLast().map(\.location)
            items.append(URLQueryItem(name: "waypoints", value: middle.joined(separator: "|")))
        }
        components.queryItems = items
        return components.url!
    }

    private func singleStopURL(for item: ItineraryItem) -> URL {
        var components = URLComponents(string: "https://www.google.com/maps/search/")!
        components.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: item.location)
        ]
        return components.url!
    }
}

#Preview {
    let trip = Trip(name: "Japan Trip", destination: "Japan", startDate: .now, endDate: .now)
    trip.items = [
        ItineraryItem(title: "Arrive Tokyo", type: .flight, date: .now, location: "Narita Airport, Tokyo", trip: trip),
        ItineraryItem(title: "Check in", type: .hotel, date: .now.addingTimeInterval(3600), location: "Park Hyatt Tokyo", trip: trip),
        ItineraryItem(title: "Bullet train", type: .transport, date: .now.addingTimeInterval(86400), location: "Kyoto Station", trip: trip)
    ]
    return NavigationStack { RouteMapView(trip: trip) }
}
