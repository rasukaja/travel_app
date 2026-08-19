import SwiftUI
import SwiftData

/// Shows one trip's itinerary as a chronological timeline, and lets you
/// add, edit, or delete entries.
struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingAddItem = false
    @State private var isShowingImport = false
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
                Menu {
                    Button {
                        isShowingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                    Button {
                        isShowingImport = true
                    } label: {
                        Label("Import Itinerary…", systemImage: "square.and.arrow.down")
                    }
                    NavigationLink {
                        RouteMapView(trip: trip)
                    } label: {
                        Label("Route", systemImage: "map")
                    }
                    NavigationLink {
                        PackingListView(trip: trip)
                    } label: {
                        Label("Packing List", systemImage: "checklist")
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingAddItem) {
            AddEditItineraryItemView(trip: trip)
        }
        .sheet(isPresented: $isShowingImport) {
            ImportItineraryView(trip: trip)
        }
        .sheet(item: $editingItem) { item in
            AddEditItineraryItemView(trip: trip, item: item)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let sorted = trip.sortedItems
        for index in offsets {
            let item = sorted[index]
            NotificationManager.shared.cancelReminder(for: item)
            modelContext.delete(item)
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
    .modelContainer(for: [Trip.self, ItineraryItem.self, PackingItem.self, TravelDocument.self], inMemory: true)
}
