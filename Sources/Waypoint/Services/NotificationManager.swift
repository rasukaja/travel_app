import Foundation
import UserNotifications

/// Wraps local (on-device) reminder notifications for itinerary items.
/// Everything here is local — no push server, no account, nothing leaves
/// the phone.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    /// How long before an item's date to fire the reminder.
    private let leadTime: TimeInterval = 60 * 60 // 1 hour

    private init() {}

    /// Requests notification permission once. Safe to call on every launch —
    /// does nothing if the user already answered (granted or denied).
    func requestAuthorizationIfNeeded() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Identifier used for an item's scheduled notification, so it can be
    /// found again to cancel or replace it.
    private func identifier(for item: ItineraryItem) -> String {
        "waypoint.reminder.\(item.persistentModelID.hashValue)"
    }

    /// Schedules or cancels this item's reminder to match its current
    /// `remindMe` flag and date. Call after any save (create/edit).
    func syncReminder(for item: ItineraryItem) {
        let id = identifier(for: item)
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard item.remindMe else { return }
        let fireDate = item.date.addingTimeInterval(-leadTime)
        guard fireDate > .now else { return } // don't schedule reminders in the past

        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = reminderBody(for: item)
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    /// Cancels a reminder outright, e.g. when the item is deleted.
    func cancelReminder(for item: ItineraryItem) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: item)])
    }

    private func reminderBody(for item: ItineraryItem) -> String {
        let time = item.date.formatted(date: .omitted, time: .shortened)
        if item.location.isEmpty {
            return "Starts at \(time)."
        }
        return "\(item.location) — starts at \(time)."
    }
}
