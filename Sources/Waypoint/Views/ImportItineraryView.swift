import SwiftUI
import SwiftData
import PDFKit
import UniformTypeIdentifiers

/// Lets the user import a PDF (boarding pass, confirmation, itinerary) or
/// paste text, then review and confirm which detected entries actually get
/// added to the trip's timeline. Nothing is saved until the user taps
/// "Add Selected" — automatic extraction is never trusted blindly.
struct ImportItineraryView: View {
    let trip: Trip
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var pastedText = ""
    @State private var drafts: [ImportedItemDraft] = []
    @State private var isShowingFileImporter = false
    @State private var importError: String?

    var body: some View {
        NavigationStack {
            Form {
                if drafts.isEmpty {
                    Section("Import From") {
                        Button {
                            isShowingFileImporter = true
                        } label: {
                            Label("Choose PDF…", systemImage: "doc.badge.plus")
                        }
                    }
                    Section {
                        TextEditor(text: $pastedText)
                            .frame(minHeight: 160)
                    } header: {
                        Text("Or Paste Text")
                    } footer: {
                        Text("Paste a booking confirmation, e-ticket, or itinerary email.")
                    }
                    Section {
                        Button("Find Itinerary Items") {
                            runParse(on: pastedText)
                        }
                        .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                } else {
                    Section {
                        Text("Review what was found, adjust anything that's wrong, then add the ones you want.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Section("Suggested Entries") {
                        ForEach($drafts) { $draft in
                            DraftRow(draft: $draft)
                        }
                    }
                    Section {
                        Button("Start Over", role: .destructive) {
                            drafts = []
                            pastedText = ""
                        }
                    }
                }
            }
            .navigationTitle("Import Itinerary")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if !drafts.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add Selected") { addSelected() }
                            .disabled(!drafts.contains { $0.isSelected && $0.date != nil })
                    }
                }
            }
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.pdf]
            ) { result in
                extractPDFText(result)
            }
            .alert("Couldn't import that file", isPresented: .constant(importError != nil), actions: {
                Button("OK") { importError = nil }
            }, message: {
                Text(importError ?? "")
            })
        }
    }

    private func runParse(on text: String) {
        drafts = ItineraryImportParser.parse(text)
        if drafts.isEmpty {
            importError = "No dates or itinerary-looking lines were found in that text. You can still add entries manually."
        }
    }

    private func extractPDFText(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            guard let document = PDFDocument(url: url) else {
                importError = "That file couldn't be read as a PDF."
                return
            }
            var text = ""
            for pageIndex in 0..<document.pageCount {
                guard let page = document.page(at: pageIndex) else { continue }
                text += (page.string ?? "") + "\n"
            }
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                importError = "This PDF has no extractable text (it may be a scanned image)."
                return
            }
            runParse(on: text)
        case .failure(let error):
            importError = error.localizedDescription
        }
    }

    private func addSelected() {
        for draft in drafts where draft.isSelected {
            guard let date = draft.date else { continue }
            let item = ItineraryItem(
                title: draft.title,
                type: draft.type,
                date: date,
                location: draft.location,
                notes: "Imported from: \(draft.sourceSnippet)",
                trip: trip
            )
            modelContext.insert(item)
        }
        dismiss()
    }
}

/// One editable suggestion row in the import review list.
private struct DraftRow: View {
    @Binding var draft: ImportedItemDraft

    private var dateBinding: Binding<Date> {
        Binding(
            get: { draft.date ?? .now },
            set: { draft.date = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $draft.isSelected) {
                VStack(alignment: .leading, spacing: 2) {
                    TextField("Title", text: $draft.title)
                        .font(.body.weight(.medium))
                    Text(draft.sourceSnippet)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Picker("Type", selection: $draft.type) {
                ForEach(ItineraryItemType.allCases) { type in
                    Label(type.displayName, systemImage: type.symbolName).tag(type)
                }
            }
            .pickerStyle(.menu)

            if draft.date != nil {
                DatePicker("Date & Time", selection: dateBinding)
                    .font(.subheadline)
            } else {
                Button("No date found — tap to set one") {
                    draft.date = .now
                    draft.isSelected = true
                }
                .font(.subheadline)
            }

            TextField("Location", text: $draft.location)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ImportItineraryView(
        trip: Trip(name: "Japan Trip", destination: "Tokyo", startDate: .now, endDate: .now)
    )
    .modelContainer(for: [Trip.self, ItineraryItem.self], inMemory: true)
}
