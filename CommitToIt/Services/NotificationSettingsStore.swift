//
//  NotificationSettingsStore.swift
//  CommitToIt
//

import Foundation

/// Local, UserDefaults-backed store for the two reminder offsets used when
/// scheduling task due-date notifications. Read-write ahead of a future
/// settings UI; until that UI exists, the defaults below are the effective
/// values for every user.
@MainActor
final class NotificationSettingsStore {

    static let shared = NotificationSettingsStore()

    private init() {}

    private enum Keys {
        static let firstReminderOffset = "notificationSettings.firstReminderOffset"
        static let secondReminderOffset = "notificationSettings.secondReminderOffset"
    }

    private enum Defaults {
        static let firstReminderOffset: TimeInterval = 86400 // 1 day
        static let secondReminderOffset: TimeInterval = 900  // 15 minutes
    }

    /// How long before `due_date` the first reminder fires.
    var firstReminderOffset: TimeInterval {
        get {
            guard UserDefaults.standard.object(forKey: Keys.firstReminderOffset) != nil else {
                return Defaults.firstReminderOffset
            }
            return UserDefaults.standard.double(forKey: Keys.firstReminderOffset)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.firstReminderOffset)
        }
    }

    /// How long before `due_date` the second reminder fires.
    var secondReminderOffset: TimeInterval {
        get {
            guard UserDefaults.standard.object(forKey: Keys.secondReminderOffset) != nil else {
                return Defaults.secondReminderOffset
            }
            return UserDefaults.standard.double(forKey: Keys.secondReminderOffset)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.secondReminderOffset)
        }
    }
}
