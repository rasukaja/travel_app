import SwiftUI
import SwiftData

/// A simple, checkable packing list for one trip.
struct PackingListView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var newItemTitle = ""

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Add item (e.g. Passport)", text: $newItemTitle)
                        .onSubmit(addItem)
                    Button {
                        addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            if trip.packingItems.isEmpty {
                ContentUnavailableView(
                    "Nothing on the list yet",
                    systemImage: "checklist",
                    description: Text("Add what you need to pack above.")
                )
            } else {
                Section("Packing List") {
                    ForEach(trip.sortedPackingItems) { item in
                        Button {
                            item.isChecked.toggle()
                        } label: {
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isChecked ? .tint : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isChecked)
                                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle("Packing List")
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        modelContext.insert(PackingItem(title: title, trip: trip))
        newItemTitle = ""
    }

    private func deleteItems(at offsets: IndexSet) {
        let sorted = trip.sortedPackingItems
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}

#Preview {
    NavigationStack {
        PackingListView(
            trip: Trip(name: "Japan Trip", destination: "Tokyo", startDate: .now, endDate: .now)
        )
    }
    .modelContainer(for: [Trip.self, ItineraryItem.self, PackingItem.self], inMemory: true)
}
