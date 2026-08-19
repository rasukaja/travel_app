import SwiftUI
import SwiftData

/// Shows one trip's itinerary as a chronological timeline, and lets you
/// add, edit, or delete entries.
struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingAddItem = false
    @State private var editingItem: ItineraryItem?

    var body: some View {
        Group {
            if trip.items.isEmpty {
                ContentUnavailableView(
                    "No Itinerary Items",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Add flights, hotels, and activities to build your timeline.")
                )
            } else {
                List {
                    ForEach(trip.sortedItems) { item in
                        Button {
                            editingItem = item
                        } label: {
                            ItineraryRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle(trip.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddItem) {
            AddEditItineraryItemView(trip: trip)
        }
        .sheet(item: $editingItem) { item in
            AddEditItineraryItemView(trip: trip, item: item)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let sorted = trip.sortedItems
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}

#Preview {
    NavigationStack {
        TripDetailView(
            trip: Trip(
                name: "Japan Trip",
                destination: "Tokyo, Japan",
                startDate: .now,
                endDate: .now.addingTimeInterval(86400 * 7)
            )
        )
    }
    .modelContainer(for: [Trip.self, ItineraryItem.self], inMemory: true)
}
