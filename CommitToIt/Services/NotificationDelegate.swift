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
        // Show notification banner, sound, and badge even when app is active
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Handle notification tap/interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Extract task information from notification
        if let taskIdString = userInfo["taskId"] as? String,
           let taskId = Int(taskIdString) {
            
            // Navigate to tasks tab
            Task { @MainActor in
                AppState.shared.selectedTab = .tasks
                
                // Optional: Could show task detail sheet here
                print("User tapped notification for task ID: \(taskId)")
            }
        }
        
        completionHandler()
    }
}
