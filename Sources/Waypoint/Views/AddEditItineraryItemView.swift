import SwiftUI
import SwiftData

/// A form sheet for adding or editing one itinerary entry on a trip.
/// Pass `item` when editing an existing entry; omit it to create a new one.
struct AddEditItineraryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    var item: ItineraryItem?

    @State private var title = ""
    @State private var type = ItineraryItemType.activity
    @State private var date = Date.now
    @State private var location = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $type) {
                        ForEach(ItineraryItemType.allCases) { itemType in
                            Label(itemType.displayName, systemImage: itemType.symbolName)
                                .tag(itemType)
                        }
                    }
                    DatePicker("Date & Time", selection: $date)
                    TextField("Location", text: $location)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(item == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadExistingItemIfNeeded)
        }
    }

    private func loadExistingItemIfNeeded() {
        guard let item else { return }
        title = item.title
        type = item.type
        date = item.date
        location = item.location
        notes = item.notes
    }

    private func save() {
        if let item {
            item.title = title
            item.type = type
            item.date = date
            item.location = location
            item.notes = notes
        } else {
            let newItem = ItineraryItem(
                title: title,
                type: type,
                date: date,
                location: location,
                notes: notes,
                trip: trip
            )
            modelContext.insert(newItem)
        }
        dismiss()
    }
}

#Preview {
    AddEditItineraryItemView(
        trip: Trip(name: "Japan Trip", destination: "Tokyo", startDate: .now, endDate: .now)
    )
    .modelContainer(for: [Trip.self, ItineraryItem.self], inMemory: true)
}
