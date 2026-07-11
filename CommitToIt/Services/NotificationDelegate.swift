//
//  NotificationDelegate.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 3/9/26.
//
import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    // MARK: - Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let request = notification.request
        let date = notification.date

        Task { @MainActor in
            NotificationInboxStore.shared.record(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                taskId: request.content.userInfo["taskId"] as? String,
                date: date
            )
        }

        // Show notification banner, sound, and badge even when app is active
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Handle notification tap/interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let request = response.notification.request
        let userInfo = request.content.userInfo
        let date = response.notification.date

        Task { @MainActor in
            // Tapping a notification opens it, so record + mark it read
            NotificationInboxStore.shared.record(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                taskId: userInfo["taskId"] as? String,
                date: date
            )
            NotificationInboxStore.shared.markAsRead(id: request.identifier)

            // Extract task information from notification
            if let taskIdString = userInfo["taskId"] as? String,
               let taskId = Int(taskIdString) {

                // Navigate to tasks tab
                AppState.shared.selectedTab = .tasks

                // Optional: Could show task detail sheet here
                print("User tapped notification for task ID: \(taskId)")
            }
        }

        completionHandler()
    }
}
