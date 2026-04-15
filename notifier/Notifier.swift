import Foundation
import AppKit

class Notifier: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    private let config: Config

    init(config: Config) {
        self.config = config
        super.init()
    }

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        // If we were launched because the user clicked a previous notification,
        // macOS gives us the notification here. Handle it and exit.
        if let userNotification = notification.userInfo?[NSApplication.launchUserNotificationUserInfoKey]
            as? NSUserNotification {
            userActivated(userNotification)
            return
        }

        // Option B: activate target app immediately, no click needed
        if config.activateImmediately, let bundleID = config.activateBundleID {
            AppActivator.activate(bundleID: bundleID)
            exit(0)
        }

        NSUserNotificationCenter.default.delegate = self

        let n = NSUserNotification()
        n.title = config.title
        n.informativeText = config.message
        n.soundName = config.sound
        if let bundleID = config.activateBundleID {
            n.userInfo = ["activateBundleID": bundleID]
        }
        NSUserNotificationCenter.default.deliver(n)
    }

    private func userActivated(_ notification: NSUserNotification) {
        NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        if let bundleID = notification.userInfo?["activateBundleID"] as? String {
            AppActivator.activate(bundleID: bundleID)
        }
        exit(0)
    }

    // MARK: - NSUserNotificationCenterDelegate

    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    // Exit right after delivery — macOS will re-launch us on click
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                didDeliver notification: NSUserNotification) {
        exit(0)
    }

    // If the user clicks while we're still running
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                didActivate notification: NSUserNotification) {
        userActivated(notification)
    }
}
