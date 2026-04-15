import AppKit
import Foundation

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)  // no Dock icon

let config = Config()
let notifier = Notifier(config: config)
notifier.run()
