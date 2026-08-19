import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import UIKit

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
    @State private var remindMe = false

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isShowingFileImporter = false
    @State private var attachmentError: String?
    @State private var previewedPhoto: TravelDocument?

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
                Section {
                    Toggle("Remind me an hour before", isOn: $remindMe)
                } footer: {
                    Text("Schedules a local notification — nothing leaves your phone.")
                }
                attachmentsSection
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
            .onChange(of: selectedPhotos) { _, newValue in
                Task { await addPhotoAttachments(newValue) }
            }
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.pdf]
            ) { result in
                addPDFAttachment(result)
            }
            .alert("Couldn't add attachment", isPresented: .constant(attachmentError != nil), actions: {
                Button("OK") { attachmentError = nil }
            }, message: {
                Text(attachmentError ?? "")
            })
            .sheet(item: $previewedPhoto) { doc in
                AttachmentPreviewView(document: doc)
            }
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        Section {
            if let item {
                ForEach(item.documents.sorted(by: { $0.createdAt < $1.createdAt })) { doc in
                    Button {
                        if doc.kind == .photo { previewedPhoto = doc }
                    } label: {
                        HStack {
                            Image(systemName: doc.kind == .photo ? "photo" : "doc.richtext")
                                .foregroundStyle(.tint)
                            Text(doc.filename)
                                .foregroundStyle(.primary)
                            Spacer()
                            if doc.kind != .photo {
                                ShareLink(item: doc.data, preview: SharePreview(doc.filename))
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in deleteAttachments(item: item, at: offsets) }

                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                }
                Button {
                    isShowingFileImporter = true
                } label: {
                    Label("Add PDF", systemImage: "doc.badge.plus")
                }
            } else {
                Text("Save this item first, then you can attach photos or PDFs (tickets, confirmations, passport scans).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Attachments")
        }
    }

    private func loadExistingItemIfNeeded() {
        guard let item else { return }
        title = item.title
        type = item.type
        date = item.date
        location = item.location
        notes = item.notes
        remindMe = item.remindMe
    }

    private func save() {
        let savedItem: ItineraryItem
        if let item {
            item.title = title
            item.type = type
            item.date = date
            item.location = location
            item.notes = notes
            item.remindMe = remindMe
            savedItem = item
        } else {
            let newItem = ItineraryItem(
                title: title,
                type: type,
                date: date,
                location: location,
                notes: notes,
                trip: trip
            )
            newItem.remindMe = remindMe
            modelContext.insert(newItem)
            savedItem = newItem
        }
        NotificationManager.shared.syncReminder(for: savedItem)
        dismiss()
    }

    // MARK: - Attachments

    @MainActor
    private func addPhotoAttachments(_ pickerItems: [PhotosPickerItem]) async {
        guard let item, !pickerItems.isEmpty else { return }
        for (index, pickerItem) in pickerItems.enumerated() {
            do {
                guard let data = try await pickerItem.loadTransferable(type: Data.self) else { continue }
                let doc = TravelDocument(
                    filename: "Photo \(item.documents.count + index + 1).jpg",
                    kind: .photo,
                    data: data,
                    item: item
                )
                modelContext.insert(doc)
            } catch {
                attachmentError = error.localizedDescription
            }
        }
        selectedPhotos = []
    }

    private func addPDFAttachment(_ result: Result<URL, Error>) {
        guard let item else { return }
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let doc = TravelDocument(
                    filename: url.lastPathComponent,
                    kind: .pdf,
                    data: data,
                    item: item
                )
                modelContext.insert(doc)
            } catch {
                attachmentError = error.localizedDescription
            }
        case .failure(let error):
            attachmentError = error.localizedDescription
        }
    }

    private func deleteAttachments(item: ItineraryItem, at offsets: IndexSet) {
        let sorted = item.documents.sorted(by: { $0.createdAt < $1.createdAt })
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}

/// Full-size look at a photo attachment.
private struct AttachmentPreviewView: View {
    let document: TravelDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let uiImage = UIImage(data: document.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("Can't preview this file", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle(document.filename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddEditItineraryItemView(
        trip: Trip(name: "Japan Trip", destination: "Tokyo", startDate: .now, endDate: .now)
    )
    .modelContainer(for: [Trip.self, ItineraryItem.self, TravelDocument.self], inMemory: true)
}
