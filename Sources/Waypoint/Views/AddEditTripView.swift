import SwiftUI
import SwiftData

/// A form sheet for creating a new trip.
struct AddEditTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date.now
    @State private var endDate = Date.now.addingTimeInterval(86400 * 3)
    @State private var emoji = "✈️"

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    TextField("Name (e.g. Summer in Italy)", text: $name)
                    TextField("Destination", text: $destination)
                    TextField("Emoji", text: $emoji)
                }
                Section("Dates") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("New Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            emoji: emoji.isEmpty ? "✈️" : emoji
        )
        modelContext.insert(trip)
        dismiss()
    }
}

#Preview {
    AddEditTripView()
        .modelContainer(for: [Trip.self, ItineraryItem.self], inMemory: true)
}
