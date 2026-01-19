// Implements: Step 7 (Error Handling & Logging)
// Defines YBSError enum with all error categories
import Foundation

/// All errors in the YBS system
enum YBSError: Error, CustomStringConvertible {
    // Configuration errors (1000-1099)
    case configNotFound(path: String)
    case configInvalidFormat(path: String, detail: String)
    case configValidationFailed(message: String)

    // File I/O errors (1100-1199)
    case fileNotFound(path: String)
    case filePermissionDenied(path: String)
    case fileReadFailed(path: String, reason: String)
    case fileWriteFailed(path: String, reason: String)

    // Tool errors (2000-2099)
    case toolNotFound(name: String)
    case toolExecutionFailed(name: String, error: String)
    case toolInvalidArguments(name: String, detail: String)
    case toolTimeout(name: String, seconds: Int)

    // LLM errors (3000-3099)
    case llmConnectionFailed(provider: String, error: String)
    case llmRequestFailed(statusCode: Int, message: String)
    case llmResponseInvalid(detail: String)
    case llmTimeout(seconds: Int)
    case llmRateLimited(retryAfter: Int?)

    // Safety errors (4000-4099)
    case sandboxViolation(path: String)
    case blockedCommand(command: String)
    case confirmationDenied(operation: String)

    // General errors (9000-9099)
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
