# Step 000006: Error Handling & Logging

**GUID**: f8e87d9f1423
**Version**: 0.1.0
**Layer**: 1 - Foundation
**Estimated Size**: ~100 lines of code

## Overview

This step implements consistent error handling and logging throughout the YBS system. It defines a centralized error type with clear categories and a simple logger with multiple levels.

Good error handling and logging are essential for debugging and understanding what the system is doing. This step establishes patterns that all other components will follow.

## What This Step Builds

**Error Handling**:
- `YBSError` enum with all error categories
- Clear, actionable error messages
- Error context (file paths, details, etc.)

**Logging**:
- Simple logger with levels (debug, info, warn, error)
- Optional colored output
- Timestamp prefixes
- Context information (component name)

## Step Objectives

1. Define `YBSError` enum with all error types
2. Implement `Logger` class with multiple levels
3. Add colored output support (optional, based on config)
4. Add convenience methods for common logging patterns
5. Create tests for error creation and logging
6. Integrate with existing config system (Step 4)

## Prerequisites

**Required Steps**:
- ✅ `ybs-step_478a8c4b0cef` - Project Skeleton
- ✅ `ybs-step_3a85545f660c` - Configuration (for UI.color setting)

**Required Conditions**:
- Swift project compiles

## Configurable Values

**This step reads configuration values**:

- `{{CONFIG:ui.color|boolean|Enable colored output|true}}` - Used to enable/disable ANSI colors in logs

## Traceability

**Implements**:
- `ybs-spec.md` Section 2 (Error Handling Standards)
- Best practices from `ybs-lessons-learned.md` Section 2.4 (Structured error returns)

**References**:
- D15 (Error Handling: Graceful degradation, no fatal crashes)

## Instructions

### Before Starting

1. **Record start time**: `date -u +"%Y-%m-%d %H:%M UTC"`
2. **Verify prerequisites**: Steps 0-5 complete, project builds
3. **Check config system**: Verify config loading works (Step 4)

### 1. Define Error Types

Create comprehensive error enum covering all error categories.

**File to create**: `Sources/YBS/Core/YBSError.swift`

```swift
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
```

### 2. Implement Logger

Create a simple logger with levels and optional colors.

**File to create**: `Sources/YBS/Core/Logger.swift`

```swift
import Foundation

/// Logger with multiple levels and optional colored output
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
```

### 3. Add Tests

Create tests for errors and logging.

**File to create**: `Tests/YBSTests/ErrorTests.swift`

```swift
import XCTest
@testable import YBS

final class ErrorTests: XCTestCase {
    func testConfigError() {
        let error = YBSError.configNotFound(path: "/etc/ybs/config.json")

        XCTAssertEqual(error.errorCode, 1000)
        XCTAssertTrue(error.description.contains("config"))
        XCTAssertTrue(error.description.contains("/etc/ybs/config.json"))
    }

    func testFileError() {
        let error = YBSError.fileNotFound(path: "test.txt")

        XCTAssertEqual(error.errorCode, 1100)
        XCTAssertTrue(error.description.contains("File not found"))
        XCTAssertTrue(error.description.contains("test.txt"))
    }

    func testToolError() {
        let error = YBSError.toolExecutionFailed(name: "read_file", error: "Permission denied")

        XCTAssertEqual(error.errorCode, 2000)
        XCTAssertTrue(error.description.contains("read_file"))
        XCTAssertTrue(error.description.contains("Permission denied"))
    }

    func testLLMError() {
        let error = YBSError.llmRequestFailed(statusCode: 429, message: "Rate limited")

        XCTAssertEqual(error.errorCode, 3000)
        XCTAssertTrue(error.description.contains("429"))
        XCTAssertTrue(error.description.contains("Rate limited"))
    }

    func testSafetyError() {
        let error = YBSError.sandboxViolation(path: "~/.ssh/id_rsa")

        XCTAssertEqual(error.errorCode, 4000)
        XCTAssertTrue(error.description.contains("Sandbox"))
        XCTAssertTrue(error.description.contains("~/.ssh/id_rsa"))
    }
}
```

**File to create**: `Tests/YBSTests/LoggerTests.swift`

```swift
import XCTest
@testable import YBS

final class LoggerTests: XCTestCase {
    func testLoggerCreation() {
        let logger = Logger(component: "Test", useColor: false)

        // Logger should not crash when logging
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warn("Warning message")
        logger.error("Error message")
    }

    func testLoggerWithError() {
        let logger = Logger(component: "Test", useColor: false)
        let error = YBSError.fileNotFound(path: "test.txt")

        // Should not crash
        logger.error(error)
    }

    func testColoredLogging() {
        let logger = Logger(component: "Test", useColor: true)

        // Should not crash with colors
        logger.info("Colored message")
    }

    func testStaticLogger() {
        // Should not crash
        Logger.info("Static info")
        Logger.error("Static error")
    }
}
```

### 4. Build and Test

Verify error handling and logging work.

**Commands**:
```bash
# Build
swift build

# Run tests
swift test --filter ErrorTests
swift test --filter LoggerTests
```

## Verification

### Build Verification

```bash
cd systems/bootstrap/builds/test6
swift build
# Expected: Build succeeds
```

### Test Verification

```bash
swift test --filter ErrorTests
swift test --filter LoggerTests
# Expected: All tests pass
```

### Manual Verification

Create a test program to see colored output:

```bash
# Create test file
cat > test-logging.swift << 'EOF'
import YBS

let logger = Logger(component: "TestApp", useColor: true)

logger.debug("This is a debug message")
logger.info("This is an info message")
logger.warn("This is a warning message")
logger.error("This is an error message")

let error = YBSError.fileNotFound(path: "/nonexistent/file.txt")
logger.error(error)

print("\nError details:")
print("Code: \(error.errorCode)")
print("Message: \(error.description)")
EOF

# Run (if you have a way to run Swift with the module)
```

**Expected Output** (with colors):
```
[2026-01-17T17:05:00Z] [TestApp] [DEBUG] This is a debug message
[2026-01-17T17:05:00Z] [TestApp] [INFO] This is an info message
[2026-01-17T17:05:00Z] [TestApp] [WARN] This is a warning message
[2026-01-17T17:05:00Z] [TestApp] [ERROR] This is an error message
[2026-01-17T17:05:00Z] [TestApp] [ERROR] File not found: /nonexistent/file.txt

Error details:
Code: 1100
Message: File not found: /nonexistent/file.txt
```

## Completion Checklist

When this step is complete, verify:

- [ ] YBSError enum defined in `Sources/YBS/Core/YBSError.swift`
- [ ] Logger class defined in `Sources/YBS/Core/Logger.swift`
- [ ] All error categories covered
- [ ] Tests created for errors and logging
- [ ] `swift build` succeeds
- [ ] `swift test` passes all tests
- [ ] Colored output works
- [ ] Error messages are clear and actionable

## After Completion

**Record completion**:
1. Note completion timestamp
2. Create DONE file: `docs/build-history/ybs-step_f8e87d9f1423-DONE.txt`
3. Update BUILD_STATUS.md

**DONE file contents**:
```
Step: ybs-step_f8e87d9f1423
Title: Error Handling & Logging
Status: COMPLETED
Started: [timestamp]
Completed: [timestamp]
Duration: [duration]

Changes:
- Created Sources/YBS/Core/YBSError.swift
- Created Sources/YBS/Core/Logger.swift
- Created Tests/YBSTests/ErrorTests.swift
- Created Tests/YBSTests/LoggerTests.swift
- All tests passing

Verification:
✓ Build succeeds
✓ All tests pass
✓ Error categories comprehensive
✓ Logging works with colors
✓ Error messages clear
```

**Commit**:
```bash
git add -A
git commit -m "Step 6: Implement error handling and logging

- Add YBSError enum with all error categories
- Add Logger class with debug/info/warn/error levels
- Support colored output (ANSI colors)
- Clear, actionable error messages
- Comprehensive tests for errors and logging

Implements: ybs-spec.md Section 2, ybs-lessons-learned.md Section 2.4

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: `ybs-step_[next-guid]` - Step 7: CLI Argument Parsing

**Dependencies satisfied**: Error handling and logging are now available for all future components.
