import Foundation
import UserNotifications
import AppKit

class Notifier: NSObject, UNUserNotificationCenterDelegate {

    private let config: Config

    init(config: Config) {
        self.config = config
        super.init()
        // Delegate must be set before requestAuthorization
        UNUserNotificationCenter.current().delegate = self
    }

    func run() {
        requestPermissionAndNotify()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: config.timeout))
        exit(0)
    }

    private func requestPermissionAndNotify() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                self.sendNotification()
            } else {
                self.playFallbackSound()
                exit(0)
            }
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = config.title
        content.body = config.message
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: config.sound))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "claude-notifier-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if error != nil { exit(1) }
        }
    }

    private func playFallbackSound() {
        let task = Process()
        task.launchPath = "/usr/bin/afplay"
        task.arguments = ["/System/Library/Sounds/\(config.sound).aiff"]
        try? task.run()
        task.waitUntilExit()
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Required: allows banner to show even when this process is considered "foreground"
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handler([.banner, .sound])
    }

    // Called when the user clicks the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler handler: @escaping () -> Void
    ) {
        if let bundleID = config.activateBundleID {
            AppActivator.activate(bundleID: bundleID)
        }
        handler()
        exit(0)
    }
}
