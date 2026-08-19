import SwiftUI

/// A single row in a trip's timeline (used by TripDetailView).
struct ItineraryRow: View {
    let item: ItineraryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.symbolName)
                .font(.title3)
                .frame(width: 32, height: 32)
                .background(.tint.opacity(0.15), in: Circle())
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    if item.remindMe {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if !item.documents.isEmpty {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                if !item.location.isEmpty {
                    Text(item.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.date, style: .date)
                    .font(.caption)
                Text(item.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ItineraryRow(item: ItineraryItem(title: "Flight to Tokyo", type: .flight, location: "Narita Airport"))
        ItineraryRow(item: ItineraryItem(title: "Check in", type: .hotel, location: "Park Hyatt Tokyo"))
    }
}
