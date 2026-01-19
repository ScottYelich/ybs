// Implements: Step 7 (Error Handling & Logging) + ybs-spec.md § 2.3 (Logging Configuration)
// Logger with console and file output, per-session log files
import Foundation

/// Logger with multiple levels, optional colored output, and file logging
class Logger {
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"

        var color: String {
            switch self {
            case .debug: return "\u{001B}[36m" // Cyan
            case .info: return "\u{001B}[32m"  // Green
            case .warn: return "\u{001B}[33m"  // Yellow
            case .error: return "\u{001B}[31m" // Red
            }
        }

        var priority: Int {
            switch self {
            case .debug: return 0
            case .info: return 1
            case .warn: return 2
            case .error: return 3
            }
        }
    }

    private let component: String
    private let useColor: Bool
    private static let resetColor = "\u{001B}[0m"
    private static var fileHandle: FileHandle?
    private static var logFilePath: String?
    private static var sessionId: String?
    private static var consoleMinLevel: Level = .info  // Default: don't show debug on console
    private static var consoleLoggingDisabled: Bool = false  // Set to true for "none"

    init(component: String, useColor: Bool = true) {
        self.component = component
        self.useColor = useColor
    }

    /// Initialize file logging with session ID
    static func initializeFileLogging(logDirectory: String = "~/.config/ybs/logs") {
        // Generate session ID (8 random hex characters)
        sessionId = String(format: "%08x", arc4random())

        // Expand tilde in path
        let expandedPath = NSString(string: logDirectory).expandingTildeInPath

        // Create directory if needed
        try? FileManager.default.createDirectory(
            atPath: expandedPath,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Generate log filename with session ID and timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let filename = "ybs-\(sessionId!)-\(timestamp).log"
        logFilePath = "\(expandedPath)/\(filename)"

        // Create/open log file
        FileManager.default.createFile(atPath: logFilePath!, contents: nil, attributes: nil)
        fileHandle = FileHandle(forWritingAtPath: logFilePath!)

        // Write header
        if let handle = fileHandle {
            let header = "=== YBS Log Session: \(sessionId!) ===\n"
            let headerLine = "Started: \(ISO8601DateFormatter().string(from: Date()))\n"
            let separator = "========================================\n\n"
            if let data = (header + headerLine + separator).data(using: .utf8) {
                handle.write(data)
            }
        }
    }

    /// Get current log file path
    static func getLogFilePath() -> String? {
        return logFilePath
    }

    /// Set minimum console log level (messages below this won't print to console, but still go to file)
    static func setConsoleLogLevel(_ levelString: String) {
        switch levelString.lowercased() {
        case "none", "silent", "quiet":
            consoleLoggingDisabled = true
        case "debug":
            consoleLoggingDisabled = false
            consoleMinLevel = .debug
        case "info":
            consoleLoggingDisabled = false
            consoleMinLevel = .info
        case "warn", "warning":
            consoleLoggingDisabled = false
            consoleMinLevel = .warn
        case "error":
            consoleLoggingDisabled = false
            consoleMinLevel = .error
        default:
            consoleLoggingDisabled = false
            consoleMinLevel = .info  // Default to info if unknown
        }
    }

    func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    func info(_ message: String) {
        log(level: .info, message: message)
    }

    func warn(_ message: String) {
        log(level: .warn, message: message)
    }

    func error(_ message: String) {
        log(level: .error, message: message)
    }

    func error(_ error: Error) {
        log(level: .error, message: error.localizedDescription)
    }

    private func log(level: Level, message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let prefix = "[\(timestamp)] [\(component)] [\(level.rawValue)]"

        // Console output (with optional colors) - only if console logging enabled and level >= consoleMinLevel
        if !Logger.consoleLoggingDisabled && level.priority >= Logger.consoleMinLevel.priority {
            if useColor {
                print("\(level.color)\(prefix)\(Logger.resetColor) \(message)")
            } else {
                print("\(prefix) \(message)")
            }
        }

        // File output (plain text, no colors) - ALWAYS write to file regardless of console level
        if let handle = Logger.fileHandle {
            let logLine = "\(prefix) \(message)\n"
            if let data = logLine.data(using: .utf8) {
                handle.write(data)
            }
        }
    }

    // Static convenience methods for global logging
    static func debug(_ message: String) {
        Logger(component: "YBS", useColor: true).debug(message)
    }

    static func info(_ message: String) {
        Logger(component: "YBS", useColor: true).info(message)
    }

    static func warn(_ message: String) {
        Logger(component: "YBS", useColor: true).warn(message)
    }

    static func error(_ message: String) {
        Logger(component: "YBS", useColor: true).error(message)
    }

    static func error(_ error: Error) {
        Logger(component: "YBS", useColor: true).error(error)
    }
}
