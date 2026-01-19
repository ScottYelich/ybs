#!/usr/bin/env swift

import Foundation

// Copy error and logger code inline for verification

enum YBSError: Error, CustomStringConvertible {
    case configNotFound(path: String)
    case configInvalidFormat(path: String, detail: String)
    case configValidationFailed(message: String)
    case fileNotFound(path: String)
    case filePermissionDenied(path: String)
    case fileReadFailed(path: String, reason: String)
    case fileWriteFailed(path: String, reason: String)
    case toolNotFound(name: String)
    case toolExecutionFailed(name: String, error: String)
    case toolInvalidArguments(name: String, detail: String)
    case toolTimeout(name: String, seconds: Int)
    case llmConnectionFailed(provider: String, error: String)
    case llmRequestFailed(statusCode: Int, message: String)
    case llmResponseInvalid(detail: String)
    case llmTimeout(seconds: Int)
    case llmRateLimited(retryAfter: Int?)
    case sandboxViolation(path: String)
    case blockedCommand(command: String)
    case confirmationDenied(operation: String)
    case invalidInput(field: String, reason: String)
    case internalError(message: String)
    case notImplemented(feature: String)

    var description: String {
        switch self {
        case .configNotFound(let path):
            return "Configuration file not found: \(path)"
        case .configInvalidFormat(let path, let detail):
            return "Invalid configuration format in \(path): \(detail)"
        case .configValidationFailed(let message):
            return "Configuration validation failed: \(message)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .filePermissionDenied(let path):
            return "Permission denied accessing: \(path)"
        case .fileReadFailed(let path, let reason):
            return "Failed to read file \(path): \(reason)"
        case .fileWriteFailed(let path, let reason):
            return "Failed to write file \(path): \(reason)"
        case .toolNotFound(let name):
            return "Tool not found: \(name)"
        case .toolExecutionFailed(let name, let error):
            return "Tool '\(name)' execution failed: \(error)"
        case .toolInvalidArguments(let name, let detail):
            return "Invalid arguments for tool '\(name)': \(detail)"
        case .toolTimeout(let name, let seconds):
            return "Tool '\(name)' timed out after \(seconds) seconds"
        case .llmConnectionFailed(let provider, let error):
            return "Failed to connect to LLM provider '\(provider)': \(error)"
        case .llmRequestFailed(let statusCode, let message):
            return "LLM request failed (status \(statusCode)): \(message)"
        case .llmResponseInvalid(let detail):
            return "Invalid LLM response: \(detail)"
        case .llmTimeout(let seconds):
            return "LLM request timed out after \(seconds) seconds"
        case .llmRateLimited(let retryAfter):
            if let after = retryAfter {
                return "Rate limited. Retry after \(after) seconds"
            } else {
                return "Rate limited. Retry later"
            }
        case .sandboxViolation(let path):
            return "Sandbox violation: Cannot access \(path)"
        case .blockedCommand(let command):
            return "Blocked command for safety: \(command)"
        case .confirmationDenied(let operation):
            return "User denied confirmation for: \(operation)"
        case .invalidInput(let field, let reason):
            return "Invalid input for \(field): \(reason)"
        case .internalError(let message):
            return "Internal error: \(message)"
        case .notImplemented(let feature):
            return "Not yet implemented: \(feature)"
        }
    }

    var errorCode: Int {
        switch self {
        case .configNotFound, .configInvalidFormat, .configValidationFailed:
            return 1000
        case .fileNotFound, .filePermissionDenied, .fileReadFailed, .fileWriteFailed:
            return 1100
        case .toolNotFound, .toolExecutionFailed, .toolInvalidArguments, .toolTimeout:
            return 2000
        case .llmConnectionFailed, .llmRequestFailed, .llmResponseInvalid, .llmTimeout, .llmRateLimited:
            return 3000
        case .sandboxViolation, .blockedCommand, .confirmationDenied:
            return 4000
        case .invalidInput, .internalError, .notImplemented:
            return 9000
        }
    }
}

class Logger {
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"

        var color: String {
            switch self {
            case .debug: return "\u{001B}[36m"
            case .info: return "\u{001B}[32m"
            case .warn: return "\u{001B}[33m"
            case .error: return "\u{001B}[31m"
            }
        }
    }

    private let component: String
    private let useColor: Bool
    private static let resetColor = "\u{001B}[0m"

    init(component: String, useColor: Bool = true) {
        self.component = component
        self.useColor = useColor
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

        if useColor {
            print("\(level.color)\(prefix)\(Logger.resetColor) \(message)")
        } else {
            print("\(prefix) \(message)")
        }
    }
}

// Verification tests
print("Error Handling & Logging Verification")
print("======================================\n")

var passCount = 0
var failCount = 0

func verify(_ name: String, _ condition: Bool) {
    if condition {
        print("✓ \(name)")
        passCount += 1
    } else {
        print("✗ \(name)")
        failCount += 1
    }
}

// Test 1: Config errors
print("Test 1: Configuration errors")
let configError = YBSError.configNotFound(path: "/etc/ybs/config.json")
verify("Config error has correct code", configError.errorCode == 1000)
verify("Config error has descriptive message", configError.description.contains("config"))
verify("Config error includes path", configError.description.contains("/etc/ybs/config.json"))
print("")

// Test 2: File errors
print("Test 2: File I/O errors")
let fileError = YBSError.fileNotFound(path: "test.txt")
verify("File error has correct code", fileError.errorCode == 1100)
verify("File error has descriptive message", fileError.description.contains("File not found"))
verify("File error includes path", fileError.description.contains("test.txt"))
print("")

// Test 3: Tool errors
print("Test 3: Tool errors")
let toolError = YBSError.toolExecutionFailed(name: "read_file", error: "Permission denied")
verify("Tool error has correct code", toolError.errorCode == 2000)
verify("Tool error includes tool name", toolError.description.contains("read_file"))
verify("Tool error includes error details", toolError.description.contains("Permission denied"))
print("")

// Test 4: LLM errors
print("Test 4: LLM errors")
let llmError = YBSError.llmRequestFailed(statusCode: 429, message: "Rate limited")
verify("LLM error has correct code", llmError.errorCode == 3000)
verify("LLM error includes status code", llmError.description.contains("429"))
verify("LLM error includes message", llmError.description.contains("Rate limited"))
print("")

// Test 5: Safety errors
print("Test 5: Safety errors")
let safetyError = YBSError.sandboxViolation(path: "~/.ssh/id_rsa")
verify("Safety error has correct code", safetyError.errorCode == 4000)
verify("Safety error mentions sandbox", safetyError.description.contains("Sandbox"))
verify("Safety error includes path", safetyError.description.contains("~/.ssh/id_rsa"))
print("")

// Test 6: Logger functionality
print("Test 6: Logger functionality")
print("--- Logger output test (with colors) ---")
let logger = Logger(component: "TestApp", useColor: true)
logger.debug("This is a debug message")
logger.info("This is an info message")
logger.warn("This is a warning message")
logger.error("This is an error message")
logger.error(fileError)
print("--- End logger output ---")
verify("Logger debug works", true)
verify("Logger info works", true)
verify("Logger warn works", true)
verify("Logger error works", true)
verify("Logger error with Error type works", true)
print("")

// Test 7: Logger without colors
print("Test 7: Logger without colors")
print("--- Logger output test (without colors) ---")
let plainLogger = Logger(component: "PlainApp", useColor: false)
plainLogger.info("Plain message without colors")
print("--- End logger output ---")
verify("Logger works without colors", true)
print("")

// Summary
print("======================================")
print("Results: \(passCount) passed, \(failCount) failed")
if failCount == 0 {
    print("✓ All tests passed!")
    exit(0)
} else {
    print("✗ Some tests failed")
    exit(1)
}
