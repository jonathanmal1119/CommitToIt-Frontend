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
    
    // MARK: - Task Due Tomorrow Reminder
    
    /// Schedule a notification for 24 hours before task is due
    /// - Parameters:
    ///   - taskId: Unique task identifier (used as notification ID)
    ///   - taskTitle: The task title to display
    ///   - dueDate: When the task is due
    /// - Note: Notification will be scheduled for 24 hours before the due date
    func scheduleTaskDueTomorrowReminder(
        taskId: Int,
        taskTitle: String,
        dueDate: Date
    ) async throws {
        // Calculate notification time (24 hours before due date)
        let notificationDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: dueDate
        ) ?? dueDate
        
        // Only schedule if notification time is in the future
        guard notificationDate > Date() else {
            #if DEBUG
            print("⚠️ Task \(taskId) due date is less than 24 hours away - skipping notification")
            #endif
            return
        }
        
        // Check authorization
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            #if DEBUG
            print("⚠️ Notification permission not granted")
            #endif
            return
        }
        
        let identifier = "task_\(taskId)"
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Due Tomorrow"
        content.body = taskTitle
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.userInfo = [
            "taskId": String(taskId),
            "type": "taskDueTomorrow"
        ]
        
        // Create calendar-based trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        // Create and add notification request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        
        #if DEBUG
        print("✓ Scheduled notification for task \(taskId) at \(notificationDate.formatted())")
        #endif
    }
    
    /// Cancel task reminder notification
    /// - Parameter taskId: The task ID
    func cancelTaskReminder(taskId: Int) {
        let identifier = "task_\(taskId)"
        cancelNotification(withIdentifier: identifier)
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
