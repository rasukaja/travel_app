import Foundation

/// One candidate itinerary entry found in an imported document, awaiting
/// the user's review before it's actually saved.
struct ImportedItemDraft: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var type: ItineraryItemType
    var date: Date?
    var location: String
    /// The line(s) of source text this draft was built from — shown to the
    /// user so they can judge whether the guess is right.
    var sourceSnippet: String
    /// Whether the user has this draft checked for import (defaults to true
    /// when we're at least reasonably confident, i.e. a date was found).
    var isSelected: Bool
}

/// Turns pasted or PDF-extracted text (booking confirmations, e-tickets,
/// itineraries) into candidate timeline entries.
///
/// This is intentionally simple, heuristic, on-device pattern matching —
/// no network calls, no ML model. It optimizes for "usually gets the date
/// and general gist right, and always lets the user confirm/correct before
/// anything is saved" rather than perfect extraction.
enum ItineraryImportParser {
    /// Splits raw text into non-empty, trimmed lines.
    private static func lines(of text: String) -> [String] {
        text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// Very small keyword table used to guess the entry type and a title
    /// from the text surrounding a detected date. Order matters — first
    /// match wins.
    private static let typeKeywords: [(keywords: [String], type: ItineraryItemType)] = [
        (["flight", "flug", "boarding", "gate", "departure", "airline", "airport"], .flight),
        (["hotel", "check-in", "check in", "reservation", "unterkunft", "resort", "hostel"], .hotel),
        (["rental car", "mietwagen", "train", "zug", "bus", "taxi", "transfer", "car hire"], .transport),
        (["ticket", "tour", "reservation for", "activity", "eintritt", "aktivität"], .activity)
    ]

    /// Attempts to pull a location out of a line: text after "at "/"in "/"to "
    /// or after a comma, falling back to the line itself if it's short.
    private static func guessLocation(in line: String) -> String {
        let lower = line.lowercased()
        for marker in [" at ", " in ", " to ", " von ", " nach "] {
            if let range = lower.range(of: marker) {
                let tail = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !tail.isEmpty && tail.count < 60 { return tail }
            }
        }
        if line.count < 60 { return line }
        return ""
    }

    private static func guessType(in text: String) -> ItineraryItemType {
        let lower = text.lowercased()
        for entry in typeKeywords {
            if entry.keywords.contains(where: { lower.contains($0) }) {
                return entry.type
            }
        }
        return .activity
    }

    private static func guessTitle(in line: String, type: ItineraryItemType) -> String {
        // Prefer the part of the line before a colon or dash, if present
        // and reasonably title-shaped; otherwise fall back to the type name.
        let separators = CharacterSet(charactersIn: ":–—-")
        if let range = line.rangeOfCharacter(from: separators) {
            let head = String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            if head.count > 3 && head.count < 60 { return head }
        }
        if line.count < 60 { return line }
        return type.displayName
    }

    /// Parses `text` and returns candidate itinerary entries, one per
    /// detected date/time, in the order they appear.
    static func parse(_ text: String) -> [ImportedItemDraft] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        var drafts: [ImportedItemDraft] = []

        for line in lines(of: text) {
            guard let detector else { break }
            let range = NSRange(line.startIndex..., in: line)
            let matches = detector.matches(in: line, options: [], range: range)
            guard let match = matches.first, let date = match.date else { continue }

            let type = guessType(in: line)
            drafts.append(
                ImportedItemDraft(
                    title: guessTitle(in: line, type: type),
                    type: type,
                    date: date,
                    location: guessLocation(in: line),
                    sourceSnippet: line,
                    isSelected: true
                )
            )
        }

        // Lines that clearly look relevant (hotel/flight keywords) but had
        // no detectable date still get surfaced, unchecked by default, so
        // the user can add the date by hand instead of losing the entry.
        for line in lines(of: text) {
            let lower = line.lowercased()
            let looksRelevant = typeKeywords.contains { $0.keywords.contains(where: { lower.contains($0) }) }
            guard looksRelevant else { continue }
            guard !drafts.contains(where: { $0.sourceSnippet == line }) else { continue }

            let type = guessType(in: line)
            drafts.append(
                ImportedItemDraft(
                    title: guessTitle(in: line, type: type),
                    type: type,
                    date: nil,
                    location: guessLocation(in: line),
                    sourceSnippet: line,
                    isSelected: false
                )
            )
        }

        return drafts
    }
}
