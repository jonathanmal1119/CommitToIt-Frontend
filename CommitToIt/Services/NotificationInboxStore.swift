//
//  NotificationInboxStore.swift
//  CommitToIt
//

import Foundation
import Combine
import UserNotifications

/// Local, UserDefaults-backed inbox of notifications that have actually been
/// delivered to the device (as opposed to `NotificationService`'s pending
/// scheduled requests). Backs the bell icon's unread badge and the
/// notification list on the task tab.
@MainActor
final class NotificationInboxStore: ObservableObject {

    static let shared = NotificationInboxStore()

    @Published private(set) var notifications: [AppNotification] = []

    private let defaultsKey = "notificationInbox.notifications"
    private let maxStored = 100

    private init() {
        load()
    }

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    /// Records a delivered notification into the inbox. Ignores duplicates
    /// by identifier so re-delivery syncs and delegate callbacks for the
    /// same notification don't create multiple entries.
    func record(id: String, title: String, body: String, taskId: String?, date: Date = Date()) {
        guard !notifications.contains(where: { $0.id == id }) else { return }

        let entry = AppNotification(id: id, taskId: taskId, title: title, body: body, date: date, isRead: false)
        notifications.insert(entry, at: 0)
        notifications.sort { $0.date > $1.date }

        if notifications.count > maxStored {
            notifications = Array(notifications.prefix(maxStored))
        }

        save()
    }

    /// Syncs notifications the system delivered while the app wasn't
    /// running or foregrounded, so entries aren't missed when the delegate
    /// never got a chance to fire.
    func syncDelivered(_ delivered: [UNNotification]) {
        for notification in delivered {
            let request = notification.request
            record(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                taskId: request.content.userInfo["taskId"] as? String,
                date: notification.date
            )
        }
    }

    func markAsRead(id: String) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead = true
        save()
    }

    func markAllAsRead() {
        if notifications.contains(where: { !$0.isRead }) {
            for index in notifications.indices {
                notifications[index].isRead = true
            }
            save()
        }

        // Clear the app icon's badge now that nothing is unread.
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    /// Clears (removes) a notification from the inbox.
    func clear(id: String) {
        notifications.removeAll { $0.id == id }
        save()
    }

    func clearAll() {
        notifications = []
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        notifications = (try? JSONDecoder().decode([AppNotification].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(notifications) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
