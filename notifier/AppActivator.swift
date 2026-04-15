import AppKit
import ScriptingBridge

struct AppActivator {
    static func activate(bundleID: String) {
        // ScriptingBridge is what terminal-notifier uses — more reliable than NSRunningApplication
        if let app = SBApplication(bundleIdentifier: bundleID) {
            app.activate()
        }
    }
}
