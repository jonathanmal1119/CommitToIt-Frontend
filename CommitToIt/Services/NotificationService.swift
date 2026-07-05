import Foundation
import UserNotifications

// MARK: - Notification Configuration

/// Configuration for scheduling a local notification
struct NotificationConfig {
    let identifier: String
    let title: String
    let body: String
    let subtitle: String?
    let sound: UNNotificationSound
    let badge: NSNumber?
    let userInfo: [AnyHashable: Any]
    let categoryIdentifier: String?
    let attachments: [UNNotificationAttachment]
    
    init(
        identifier: String = UUID().uuidString,
        title: String,
        body: String,
        subtitle: String? = nil,
        sound: UNNotificationSound = .default,
        badge: NSNumber? = nil,
        userInfo: [AnyHashable: Any] = [:],
        categoryIdentifier: String? = nil,
        attachments: [UNNotificationAttachment] = []
    ) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.sound = sound
        self.badge = badge
        self.userInfo = userInfo
        self.categoryIdentifier = categoryIdentifier
        self.attachments = attachments
    }
}

// MARK: - Notification Service

@MainActor
class NotificationService {
    
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission
    
    /// Request notification permission from the user
    /// - Parameter options: The notification options to request (default: alert, sound, badge)
    /// - Returns: True if permission was granted
    @discardableResult
    func requestPermission(
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) async throws -> Bool {
        // Check if already authorized to avoid unnecessary prompts
        let currentStatus = await checkAuthorizationStatus()
        if currentStatus == .authorized {
            return true
        }
        
        do {
            let granted = try await center.requestAuthorization(options: options)
            #if DEBUG
            print("Notification permission granted:", granted)
            #endif
            return granted
        } catch {
            #if DEBUG
            print("Notification permission error:", error)
            #endif
            throw error
        }
    }
    
    /// Check current notification authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Simple Notification Functions
    
    /// Send an immediate local notification
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification message
    ///   - subtitle: Optional subtitle
    ///   - identifier: Unique identifier (auto-generated if not provided)
    ///   - sound: Notification sound (default sound if not specified)
    ///   - badge: Optional badge number
    ///   - userInfo: Additional data to attach
    func sendNotification(
        title: String,
        body: String,
        subtitle: String? = nil,
        identifier: String = UUID().uuidString,
        sound: UNNotificationSound = .default,
        badge: NSNumber? = nil,
        userInfo: [AnyHashable: Any] = [:]
    ) async throws {
        let config = NotificationConfig(
            identifier: identifier,
            title: title,
            body: body,
            subtitle: subtitle,
            sound: sound,
            badge: badge,
            userInfo: userInfo
        )
        
        try await scheduleNotification(config: config, delay: nil)
    }
    
    /// Schedule a notification for a future time
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification message
    ///   - date: When to trigger the notification
    ///   - subtitle: Optional subtitle
    ///   - identifier: Unique identifier (auto-generated if not provided)
    ///   - sound: Notification sound
    ///   - badge: Optional badge number
    ///   - repeats: Whether the notification should repeat
    ///   - userInfo: Additional data to attach
    func scheduleNotification(
        title: String,
        body: String,
        at date: Date,
        subtitle: String? = nil,
        identifier: String = UUID().uuidString,
        sound: UNNotificationSound = .default,
        badge: NSNumber? = nil,
        repeats: Bool = false,
        userInfo: [AnyHashable: Any] = [:]
    ) async throws {
        // Check authorization before scheduling
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            throw NotificationError.permissionDenied
        }
        
        // Prevent scheduling notifications in the past
        guard date > Date() else {
            #if DEBUG
            print("Cannot schedule notification in the past")
            #endif
            throw NotificationError.pastDate
        }
        
        let config = NotificationConfig(
            identifier: identifier,
            title: title,
            body: body,
            subtitle: subtitle,
            sound: sound,
            badge: badge,
            userInfo: userInfo
        )
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: repeats
        )
        
        try await scheduleNotification(config: config, trigger: trigger)
    }
    
    /// Schedule a notification after a delay
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification message
    ///   - delay: Time interval in seconds before notification
    ///   - subtitle: Optional subtitle
    ///   - identifier: Unique identifier
    ///   - sound: Notification sound
    ///   - badge: Optional badge number
    ///   - userInfo: Additional data to attach
    func scheduleNotification(
        title: String,
        body: String,
        afterDelay delay: TimeInterval,
        subtitle: String? = nil,
        identifier: String = UUID().uuidString,
        sound: UNNotificationSound = .default,
        badge: NSNumber? = nil,
        userInfo: [AnyHashable: Any] = [:]
    ) async throws {
        let config = NotificationConfig(
            identifier: identifier,
            title: title,
            body: body,
            subtitle: subtitle,
            sound: sound,
            badge: badge,
            userInfo: userInfo
        )
        
        try await scheduleNotification(config: config, delay: delay)
    }
    
    // MARK: - Advanced Configuration
    
    /// Schedule a notification with full configuration options
    /// - Parameters:
    ///   - config: The notification configuration
    ///   - trigger: Custom trigger (nil for immediate)
    private func scheduleNotification(
        config: NotificationConfig,
        trigger: UNNotificationTrigger? = nil
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = config.title
        content.body = config.body
        
        if let subtitle = config.subtitle {
            content.subtitle = subtitle
        }
        
        content.sound = config.sound
        content.userInfo = config.userInfo
        
        if let badge = config.badge {
            content.badge = badge
        }
        
        if let categoryIdentifier = config.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        content.attachments = config.attachments
        
        let request = UNNotificationRequest(
            identifier: config.identifier,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        #if DEBUG
        print("✓ Notification scheduled:", config.identifier)
        #endif
    }
    
    /// Schedule a notification with a time delay
    private func scheduleNotification(
        config: NotificationConfig,
        delay: TimeInterval?
    ) async throws {
        let trigger: UNNotificationTrigger? = if let delay = delay {
            UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
        } else {
            nil
        }
        
        try await scheduleNotification(config: config, trigger: trigger)
    }
    
    // MARK: - Task Reminder (Backward Compatible)
    
    /// Schedule a task reminder notification
    func scheduleTaskReminder(
        taskId: String,
        title: String,
        dueDate: Date,
        subtitle: String? = nil
    ) async throws {
        try await scheduleNotification(
            title: "Task Due",
            body: title,
            at: dueDate,
            subtitle: subtitle,
            identifier: taskId,
            userInfo: ["taskId": taskId, "type": "taskReminder"]
        )
    }
    
    // MARK: - Task Reminders (First / Second)

    /// A task's first or second due-date reminder. Centralizes the per-kind
    /// copy and identifier so scheduling and cancellation can't drift apart.
    @MainActor
    private enum ReminderKind: CaseIterable {
        case first
        case second

        var suffix: String {
            switch self {
            case .first: return "first"
            case .second: return "second"
            }
        }

        var title: String {
            switch self {
            case .first: return "Task Reminder"
            case .second: return "Final Reminder"
            }
        }

        var userInfoType: String {
            switch self {
            case .first: return "firstReminder"
            case .second: return "secondReminder"
            }
        }

        func body(taskTitle: String) -> String {
            switch self {
            case .first: return "\"\(taskTitle)\" is due soon."
            case .second: return "\"\(taskTitle)\" is due very soon!"
            }
        }

        func offset(from settings: NotificationSettingsStore) -> TimeInterval {
            switch self {
            case .first: return settings.firstReminderOffset
            case .second: return settings.secondReminderOffset
            }
        }

        func identifier(for taskId: Int) -> String {
            "task_\(taskId)_\(suffix)"
        }
    }

    /// Schedule a task's first and second due-date reminders, reading offsets
    /// from `NotificationSettingsStore`. Any offset whose resulting fire date
    /// has already passed (or otherwise fails to schedule) is skipped
    /// silently; the other reminder still schedules independently. Also
    /// purges the legacy single-reminder identifier from older app versions.
    /// - Parameters:
    ///   - taskId: Unique task identifier (used to build notification IDs)
    ///   - taskTitle: The task title to display
    ///   - dueDate: When the task is due
    func scheduleTaskReminders(
        taskId: Int,
        taskTitle: String,
        dueDate: Date
    ) async throws {
        // Purge the legacy single-reminder identifier from the old scheme
        cancelNotification(withIdentifier: "task_\(taskId)")

        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            #if DEBUG
            print("⚠️ Notification permission not granted")
            #endif
            return
        }

        let settings = NotificationSettingsStore.shared

        for kind in ReminderKind.allCases {
            let fireDate = dueDate.addingTimeInterval(-kind.offset(from: settings))
            do {
                try await scheduleNotification(
                    title: kind.title,
                    body: kind.body(taskTitle: taskTitle),
                    at: fireDate,
                    identifier: kind.identifier(for: taskId),
                    badge: NSNumber(value: 1),
                    userInfo: ["taskId": String(taskId), "type": kind.userInfoType]
                )
                #if DEBUG
                print("✓ Scheduled \(kind.suffix) reminder for task \(taskId) at \(fireDate.formatted())")
                #endif
            } catch {
                // Independent per-reminder skip: a past fire date or any other
                // scheduling failure for one reminder must not prevent the other.
                #if DEBUG
                print("⚠️ Task \(taskId) \(kind.suffix) reminder not scheduled: \(error)")
                #endif
            }
        }
    }

    /// Cancel both of a task's reminders, plus the legacy single-reminder
    /// identifier from the old scheme.
    /// - Parameter taskId: The task ID
    func cancelTaskReminders(taskId: Int) {
        cancelNotifications(withIdentifiers:
            ReminderKind.allCases.map { $0.identifier(for: taskId) } + ["task_\(taskId)"]
        )
    }

    /// Cancel a task's existing reminders and schedule new ones reflecting an
    /// updated title/due date. Not yet called from any production flow — the
    /// task-edit save flow that will call this doesn't exist yet.
    /// - Parameters:
    ///   - taskId: Unique task identifier
    ///   - taskTitle: The updated task title
    ///   - dueDate: The updated due date
    func rescheduleTaskReminders(
        taskId: Int,
        taskTitle: String,
        dueDate: Date
    ) async throws {
        cancelTaskReminders(taskId: taskId)
        try await scheduleTaskReminders(taskId: taskId, taskTitle: taskTitle, dueDate: dueDate)
    }

    // MARK: - Cancel Notifications
    
    /// Cancel a specific notification
    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        #if DEBUG
        print("✗ Cancelled notification:", identifier)
        #endif
    }
    
    /// Cancel multiple notifications
    func cancelNotifications(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        #if DEBUG
        print("✗ Cancelled \(identifiers.count) notifications")
        #endif
    }
    
    /// Cancel a task reminder
    func cancelTaskReminder(taskId: String) {
        cancelNotification(withIdentifier: taskId)
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        #if DEBUG
        print("✗ All notifications cancelled")
        #endif
    }
    
    // MARK: - Query Notifications
    
    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    /// Get delivered notifications
    func getDeliveredNotifications() async -> [UNNotification] {
        await center.deliveredNotifications()
    }
    
    /// Check if a notification is scheduled
    func isNotificationScheduled(identifier: String) async -> Bool {
        let pending = await getPendingNotifications()
        return pending.contains { $0.identifier == identifier }
    }
    
    // MARK: - Debug
    
    /// Print all pending notifications
    func printPendingNotifications() async {
        let requests = await getPendingNotifications()
        
        guard !requests.isEmpty else {
            print("No pending notifications")
            return
        }
        
        print("📋 Pending notifications (\(requests.count)):")
        
        for request in requests {
            print("──────────────────────")
            print("ID: \(request.identifier)")
            print("Title: \(request.content.title)")
            print("Body: \(request.content.body)")
            
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                print("Scheduled for: \(nextTriggerDate)")
            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                print("Fires in: \(trigger.timeInterval) seconds")
            }
        }
        print("──────────────────────")
    }
}

// MARK: - Errors

enum NotificationError: LocalizedError {
    case pastDate
    case permissionDenied
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .pastDate:
            return "Cannot schedule notification for a past date"
        case .permissionDenied:
            return "Notification permission was denied"
        case .invalidConfiguration:
            return "Invalid notification configuration"
        }
    }
}
