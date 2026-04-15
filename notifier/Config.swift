import Foundation

struct Config {
    var title: String = "Claude Code"
    var message: String = "Done"
    var sound: String = "Glass"
    var activateBundleID: String? = nil
    var activateImmediately: Bool = false
    var timeout: TimeInterval = 5.0

    init() {
        let args = Array(CommandLine.arguments.dropFirst())
        var i = 0
        while i < args.count {
            switch args[i] {
            case "--title":
                i += 1; if i < args.count { title = args[i] }
            case "--message":
                i += 1; if i < args.count { message = args[i] }
            case "--sound":
                i += 1; if i < args.count { sound = args[i] }
            case "--activate":
                i += 1; if i < args.count { activateBundleID = args[i] }
            case "--activate-immediately":
                activateImmediately = true
            case "--timeout":
                i += 1; if i < args.count { timeout = Double(args[i]) ?? timeout }
            default:
                break
            }
            i += 1
        }
    }
}
