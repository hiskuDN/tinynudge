import AppKit

struct AppActivator {
    static func activate(bundleID: String) {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        if let app = apps.first {
            app.activate(options: .activateIgnoringOtherApps)
        }
    }
}
