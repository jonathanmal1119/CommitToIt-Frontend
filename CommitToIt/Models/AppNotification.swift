//
//  AppNotification.swift
//  CommitToIt
//

import Foundation

/// An in-app record of a local notification that was delivered to the
/// device, shown in the notification inbox on the task tab.
struct AppNotification: Codable, Identifiable, Equatable {
    let id: String
    let taskId: String?
    let title: String
    let body: String
    let date: Date
    var isRead: Bool
}
