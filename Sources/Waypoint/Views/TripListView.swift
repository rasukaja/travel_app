import SwiftUI
import SwiftData

/// The app's home screen: a list of all trips, with a button to add new ones.
struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var isShowingAddTrip = false

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "No Trips Yet",
                        systemImage: "airplane.departure",
                        description: Text("Tap + to plan your first trip.")
                    )
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink(value: trip) {
                                TripRow(trip: trip)
                            }
                        }
                        .onDelete(perform: deleteTrips)
                    }
                }
            }
            .navigationTitle("My Trips")
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddTrip = true
                    } label: {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTrip) {
                AddEditTripView()
            }
        }
    }

    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
    }
}

private struct TripRow: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 12) {
            Text(trip.emoji)
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                Text(trip.destination)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var dateRangeText: String {
        let start = trip.startDate.formatted(date: .abbreviated, time: .omitted)
        let end = trip.endDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }
}

#Preview {
    TripListView()
        .modelContainer(for: [Trip.self, ItineraryItem.self], inMemory: true)
}
