import AppKit

struct AppActivator {

    private static let processName: [String: String] = [
        "com.todesktop.230313mzl4w4u92": "Cursor",
        "com.microsoft.VSCode":           "Code",
        "com.googlecode.iterm2":          "iTerm2",
        "dev.warp.Warp-Stable":           "Warp",
        "com.mitchellh.ghostty":          "Ghostty",
        "com.apple.Terminal":             "Terminal",
    ]

    static func activate(bundleID: String, windowTitle: String? = nil) {
        if let title = windowTitle, !title.isEmpty,
           let proc = processName[bundleID] {
            raiseWindow(processName: proc, title: title)
        }
        NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleID)
            .first?
            .activate(options: [.activateIgnoringOtherApps])
    }

    private static func raiseWindow(processName: String, title: String) {
        let escaped = title.replacingOccurrences(of: "\"", with: "\\\"")
        let src = """
        tell application "System Events"
            tell process "\(processName)"
                try
                    set w to first window whose title contains "\(escaped)"
                    perform action "AXRaise" of w
                end try
            end tell
        end tell
        """
        var err: NSDictionary?
        NSAppleScript(source: src)?.executeAndReturnError(&err)
    }
}
