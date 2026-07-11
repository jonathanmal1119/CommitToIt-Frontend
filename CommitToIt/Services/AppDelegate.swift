//
//  AppDelegate.swift
//  CommitToIt
//

import UIKit

/// Hosts the Home Screen quick action (long-press on the app icon) for
/// marking all notifications as read without opening the app.
class AppDelegate: NSObject, UIApplicationDelegate {

    static let markAllReadActionType = "com.commitToIt.markAllRead"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.shortcutItems = [
            UIApplicationShortcutItem(
                type: Self.markAllReadActionType,
                localizedTitle: "Mark All as Read",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "bell.slash")
            )
        ]

        // App was launched (cold start) directly from the quick action.
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handle(shortcutItem)
        }

        return true
    }

    // App was already running (foreground/background) when the quick action was tapped.
    // Only reached pre-scenes; kept as a fallback alongside SceneDelegate below.
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(handle(shortcutItem))
    }

    // The app declares a scene manifest, so once a scene exists, quick
    // actions for an already-running app are delivered to the scene
    // delegate's windowScene(_:performActionFor:completionHandler:), not the
    // app delegate method above. Register SceneDelegate so that path is handled too.
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

    @discardableResult
    fileprivate static func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard shortcutItem.type == Self.markAllReadActionType else { return false }
        Task { @MainActor in
            NotificationInboxStore.shared.markAllAsRead()
        }
        return true
    }

    @discardableResult
    private func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        Self.handle(shortcutItem)
    }
}

/// Handles the Home Screen quick action while the app is already running —
/// scene-based apps route this through the scene delegate rather than
/// UIApplicationDelegate.application(_:performActionFor:completionHandler:).
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(AppDelegate.handle(shortcutItem))
    }
}
