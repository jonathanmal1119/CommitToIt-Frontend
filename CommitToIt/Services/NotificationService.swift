import Foundation
import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Request Permission
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                print("Notification permission error:", error)
                return
            }
            
            print("Notification permission granted:", granted)
        }
    }
    
    // MARK: - Schedule Task Reminder
    
    func scheduleTaskReminder(
        taskId: String,
        title: String,
        dueDate: Date
    ) {
        
        // Prevent scheduling notifications in the past
        if dueDate <= Date() {
            print("Cannot schedule notification in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due"
        content.body = title
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: taskId,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification:", error)
            } else {
                print("Notification scheduled for task:", taskId)
            }
        }
    }
    
    // MARK: - Cancel Reminder
    
    func cancelTaskReminder(taskId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [taskId])
        print("Cancelled notification:", taskId)
    }
    
    // MARK: - Cancel All
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    // MARK: - Debug: List Pending Notifications
    
    func printPendingNotifications() {
        center.getPendingNotificationRequests { requests in
            
            if requests.isEmpty {
                print("No pending notifications")
                return
            }
            
            print("Pending notifications:")
            
            for request in requests {
                print("ID:", request.identifier)
                print("Title:", request.content.title)
                print("Body:", request.content.body)
                print("-------------------")
            }
        }
    }
}
