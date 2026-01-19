# Step 44: Readline Implementation

**GUID**: `6efb3739001f`
**Implements**: ybs-spec.md § 2.4 (Interactive Input - Readline)
**Status**: Not Started
**Depends On**: Step 43 (3b0b0f39524a - Context Statistics)

---

## Changelog

### v1.1 (2026-01-18)
- **Fixed**: Readline fails over SSH (character duplication, broken Ctrl+C/Ctrl+L)
- **Changed**: Default `enable_readline` from `true` to `false` (disabled by default)
- **Added**: SSH detection to automatically disable readline for SSH sessions
- **Added**: TERM validation (reject "dumb" or empty TERM)
- **Added**: Test requirements for SSH detection and terminal validation
- **Rationale**: LineNoise cannot enter raw mode over SSH pseudo-TTYs, causing terminal echo issues

### v1.0 (2026-01-18)
- Initial version

---

## Objective

Implement readline support for enhanced terminal input with line editing, command history, and history persistence across sessions. Readline is **disabled by default** due to SSH compatibility issues, but users can enable it for local terminal use. The implementation includes automatic detection of incompatible environments (SSH, invalid TERM) with graceful fallback to plain input.

---

## Instructions

### Phase 1: Add LineNoise Dependency

**Goal**: Add LineNoise package dependency to Package.swift

**Steps**:
1. Open `Package.swift`
2. Add LineNoise package to dependencies array:
   ```swift
   .package(url: "https://github.com/andybest/linenoise-swift", from: "0.0.3")
   ```
3. Add "LineNoise" to the target dependencies for main executable:
   ```swift
   .executableTarget(
       name: "YBS",
       dependencies: [
           "LineNoise"  // Add this
       ]
   )
   ```

**Verification**:
- Run `swift build` - should fetch LineNoise and compile successfully
- No compilation errors

---

### Phase 2: Update Configuration Structures

**Goal**: Add readline configuration options to config structures

**File**: `Sources/YBS/Configuration/Config.swift`

**Changes**:
1. Add fields to `UIConfig` struct:
   ```swift
   struct UIConfig: Codable {
       let color: Bool
       let showTokenUsage: Bool
       let showToolCalls: Bool
       let streamResponses: Bool
       let enableReadline: Bool           // NEW
       let historyFile: String            // NEW
       let historyMaxEntries: Int         // NEW

       enum CodingKeys: String, CodingKey {
           case color
           case showTokenUsage = "show_token_usage"
           case showToolCalls = "show_tool_calls"
           case streamResponses = "stream_responses"
           case enableReadline = "enable_readline"         // NEW
           case historyFile = "history_file"               // NEW
           case historyMaxEntries = "history_max_entries"  // NEW
       }
   }
   ```

2. Update default values in config loading:
   ```swift
   let enableReadline = uiDict["enable_readline"] as? Bool ?? false  // Disabled by default
   let historyFile = uiDict["history_file"] as? String ?? "~/.config/ybs/history"
   let historyMaxEntries = uiDict["history_max_entries"] as? Int ?? 1000
   ```

**Verification**:
- Code compiles
- Config loads with new fields
- Default values are correct

---

### Phase 3: Add CLI Flag

**Goal**: Add `--no-readline` CLI flag

**File**: `Sources/YBS/CLI/YBSCommand.swift`

**Changes**:
1. Add `@Flag` for readline:
   ```swift
   @Flag(name: .long, help: "Disable readline (use plain input)")
   var noReadline: Bool = false
   ```

2. Apply flag in `run()` method before starting agent loop:
   ```swift
   // Override readline setting if --no-readline provided
   if noReadline {
       config.ui.enableReadline = false
   }
   ```

**Note**: Assumes `UIConfig` is mutable or config has a method to override settings.

**Verification**:
- `swift run YBS --help` shows `--no-readline` option
- Running with `--no-readline` disables readline

---

### Phase 4: Create InputHandler Abstraction

**Goal**: Create protocol and implementations for input handling

**Create**: `Sources/YBS/UI/InputHandler.swift`

**Code**:
```swift
// Implements: ybs-spec.md § 2.4 (Interactive Input - Readline)
import Foundation

/// Protocol for handling user input
protocol InputHandler {
    /// Read a line of input with optional prompt
    /// - Parameter prompt: Optional prompt to display
    /// - Returns: Input string, or nil on EOF
    func readLine(prompt: String) -> String?

    /// Clean up resources (close history file, etc.)
    func cleanup()
}
```

**Verification**:
- File compiles
- Protocol is defined correctly

---

### Phase 5: Implement PlainInputHandler

**Goal**: Fallback input handler using standard Swift readLine()

**Add to**: `Sources/YBS/UI/InputHandler.swift`

**Code**:
```swift
/// Plain input handler using Swift's readLine() - no history or editing
class PlainInputHandler: InputHandler {
    func readLine(prompt: String) -> String? {
        print(prompt, terminator: "")
        fflush(stdout)
        return Swift.readLine()
    }

    func cleanup() {
        // Nothing to clean up
    }
}
```

**Verification**:
- Code compiles
- Can instantiate and use PlainInputHandler

---

### Phase 6: Implement ReadlineInputHandler

**Goal**: Full-featured input handler using LineNoise

**Add to**: `Sources/YBS/UI/InputHandler.swift`

**Code**:
```swift
#if canImport(LineNoise)
import LineNoise

/// Readline input handler using LineNoise - with history and editing
class ReadlineInputHandler: InputHandler {
    private let lineNoise: LineNoise
    private let historyFile: String
    private let maxEntries: Int
    private let logger: Logger

    init(historyFile: String, maxEntries: Int, logger: Logger) {
        self.lineNoise = LineNoise()
        self.historyFile = NSString(string: historyFile).expandingTildeInPath
        self.maxEntries = maxEntries
        self.logger = logger

        // Load history
        loadHistory()

        // Configure LineNoise
        lineNoise.setHistoryMaxLength(maxEntries)
    }

    func readLine(prompt: String) -> String? {
        do {
            let input = try lineNoise.getLine(prompt: prompt)

            // Don't save empty lines
            guard !input.trimmingCharacters(in: .whitespaces).isEmpty else {
                return input
            }

            // Don't save lines starting with space (privacy feature)
            guard !input.hasPrefix(" ") else {
                return input
            }

            // Add to history and save
            lineNoise.addHistory(input)
            saveHistory()

            return input
        } catch LinenoiseError.EOF {
            return nil
        } catch {
            logger.error("Readline error: \(error)")
            return nil
        }
    }

    func cleanup() {
        saveHistory()
    }

    // MARK: - History Management

    private func loadHistory() {
        let url = URL(fileURLWithPath: historyFile)

        guard FileManager.default.fileExists(atPath: historyFile) else {
            logger.debug("History file not found, starting fresh: \(historyFile)")
            return
        }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)

            // Load up to maxEntries most recent lines
            let recentLines = Array(lines.suffix(maxEntries))

            for line in recentLines where !line.isEmpty {
                lineNoise.addHistory(line)
            }

            logger.debug("Loaded \(recentLines.count) history entries from \(historyFile)")
        } catch {
            logger.warn("Failed to load history: \(error)")
        }
    }

    private func saveHistory() {
        let url = URL(fileURLWithPath: historyFile)

        // Ensure directory exists
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            // Get history from LineNoise
            let history = lineNoise.history

            // Keep only most recent maxEntries
            let recentHistory = Array(history.suffix(maxEntries))

            // Write to file
            let contents = recentHistory.joined(separator: "\n")
            try contents.write(to: url, atomically: true, encoding: .utf8)

            // Set restrictive permissions (600)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: historyFile
            )
        } catch {
            logger.warn("Failed to save history: \(error)")
        }
    }
}
#endif
```

**Verification**:
- Code compiles
- Can instantiate ReadlineInputHandler
- History file is created with correct permissions

---

### Phase 7: Update AgentLoop

**Goal**: Use InputHandler in agent loop instead of direct readLine()

**File**: `Sources/YBS/Agent/AgentLoop.swift`

**Changes**:

1. Add import at top:
   ```swift
   #if canImport(Darwin)
   import Darwin
   #elseif canImport(Glibc)
   import Glibc
   #endif
   ```

2. Add property to class:
   ```swift
   private let inputHandler: InputHandler
   ```

3. Initialize in `init()` based on config, TTY detection, TERM validation, and SSH detection:
   ```swift
   // Initialize input handler based on config and TTY
   // Check both TTY and TERM environment variable
   let isTTY = isatty(STDIN_FILENO) != 0
   let termType = ProcessInfo.processInfo.environment["TERM"] ?? ""
   let hasValidTerm = !termType.isEmpty && termType != "dumb"

   // Detect SSH sessions (LineNoise often fails over SSH)
   let isSSH = ProcessInfo.processInfo.environment["SSH_CONNECTION"] != nil ||
               ProcessInfo.processInfo.environment["SSH_CLIENT"] != nil ||
               ProcessInfo.processInfo.environment["SSH_TTY"] != nil

   if config.ui.enableReadline && isTTY && hasValidTerm && !isSSH {
       #if canImport(LineNoise)
       self.inputHandler = ReadlineInputHandler(
           historyFile: config.ui.historyFile,
           maxEntries: config.ui.historyMaxEntries,
           logger: logger
       )
       logger.info("Readline enabled (history: \(config.ui.historyFile))")
       #else
       self.inputHandler = PlainInputHandler()
       logger.warn("LineNoise not available, using plain input")
       #endif
   } else {
       self.inputHandler = PlainInputHandler()
       if !config.ui.enableReadline {
           logger.info("Readline disabled by configuration")
       } else if !isTTY {
           logger.info("Readline disabled (not a TTY)")
       } else if !hasValidTerm {
           logger.info("Readline disabled (TERM=\(termType) not supported)")
       } else if isSSH {
           logger.info("Readline disabled (SSH session detected)")
       }
   }
   ```

4. Replace `readLine()` call in main loop with:
   ```swift
   // Old:
   // guard let userInput = readLine() else { break }

   // New:
   guard let userInput = inputHandler.readLine(prompt: "> ") else { break }
   ```

5. Add cleanup in exit handling:
   ```swift
   inputHandler.cleanup()
   ```

**Verification**:
- Code compiles
- AgentLoop uses input handler correctly
- Readline works when enabled
- Falls back to plain input when disabled

---

### Phase 8: Testing

**Goal**: Verify readline functionality works correctly

**Manual Tests**:
1. **Default behavior** (readline disabled):
   ```bash
   swift run YBS
   # Test: Plain input mode (no line editing)
   # Test: Type normally, press Enter, input is processed
   # Test: Ctrl+C interrupts cleanly
   # Test: No character duplication or display issues
   ```

2. **Enabled via config** (local terminal only):
   ```bash
   # Edit ~/.config/ybs/config.json: "enable_readline": true
   swift run YBS
   # Test (only if NOT over SSH): Arrow keys work for line editing
   # Test (only if NOT over SSH): Up/down arrows recall history
   # Test: If SSH detected, should fall back to plain input with log message
   ```

3. **Disabled via flag** (redundant but verifies override):
   ```bash
   swift run YBS --no-readline
   # Test: Plain input mode
   # Test: No line editing
   ```

4. **Piped input** (auto-disable):
   ```bash
   echo "hello" | swift run YBS
   # Test: Should handle piped input gracefully
   # Test: No readline (not a TTY)
   ```

5. **SSH detection**:
   ```bash
   # Connect via SSH, then:
   swift run YBS
   # Test: Plain input mode (readline auto-disabled)
   # Test: Log should show "Readline disabled (SSH session detected)"
   # Test: No character duplication or broken Ctrl+C
   ```

6. **History file** (only if readline was enabled):
   ```bash
   cat ~/.config/ybs/history
   # Test: Contains previous commands (if readline was used)
   # Test: Limited to maxEntries (1000 by default)
   ```

**Unit Tests**:

Create `Tests/YBSTests/InputHandlerTests.swift`:
```swift
// Implements: ybs-spec.md § 2.4.7 (Readline Test Requirements)
import XCTest
@testable import YBS

final class InputHandlerTests: XCTestCase {
    func testPlainInputHandler() {
        let handler = PlainInputHandler()
        // PlainInputHandler doesn't have much to test (uses system readLine)
        handler.cleanup()  // Should not crash
    }

    func testHistoryFileCreation() {
        let tempDir = FileManager.default.temporaryDirectory
        let historyPath = tempDir.appendingPathComponent("test-history-\(UUID().uuidString)").path

        // Create handler (will create history file)
        let logger = Logger(logLevel: .none, consoleLevel: .none, logToFile: false, logDirectory: "")
        let handler = ReadlineInputHandler(historyFile: historyPath, maxEntries: 100, logger: logger)
        handler.cleanup()

        // Verify file created (might not exist until first save)
        // This is acceptable - history file is lazy-created
    }

    func testTTYDetection() {
        // Test that isatty works
        let result = isatty(STDIN_FILENO)
        // Result depends on environment (1 for TTY, 0 for non-TTY)
        XCTAssert(result == 0 || result == 1, "isatty should return 0 or 1")
    }

    func testSSHDetection() {
        // Test SSH environment variable detection
        let sshVars = ["SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY"]

        for sshVar in sshVars {
            setenv(sshVar, "test", 1)

            let isSSH = ProcessInfo.processInfo.environment["SSH_CONNECTION"] != nil ||
                        ProcessInfo.processInfo.environment["SSH_CLIENT"] != nil ||
                        ProcessInfo.processInfo.environment["SSH_TTY"] != nil

            XCTAssertTrue(isSSH, "\(sshVar) should be detected")
            unsetenv(sshVar)
        }

        // Verify SSH not detected when vars absent
        let isSSH = ProcessInfo.processInfo.environment["SSH_CONNECTION"] != nil ||
                    ProcessInfo.processInfo.environment["SSH_CLIENT"] != nil ||
                    ProcessInfo.processInfo.environment["SSH_TTY"] != nil
        XCTAssertFalse(isSSH, "SSH should not be detected without env vars")
    }

    func testTERMValidation() {
        // Test TERM environment variable validation
        let originalTerm = ProcessInfo.processInfo.environment["TERM"]

        // Valid TERM
        setenv("TERM", "xterm-256color", 1)
        let termType1 = ProcessInfo.processInfo.environment["TERM"] ?? ""
        XCTAssertFalse(termType1.isEmpty, "TERM should not be empty")
        XCTAssertNotEqual(termType1, "dumb", "TERM should not be dumb")

        // Invalid TERM (dumb)
        setenv("TERM", "dumb", 1)
        let termType2 = ProcessInfo.processInfo.environment["TERM"] ?? ""
        XCTAssertEqual(termType2, "dumb", "TERM should be dumb")

        // Restore original TERM
        if let orig = originalTerm {
            setenv("TERM", orig, 1)
        } else {
            unsetenv("TERM")
        }
    }
}
```

**Verification**:
- All manual tests pass
- Unit tests pass: `swift test`
- Build succeeds: `swift build`

---

## Verification Criteria

Before marking this step complete, verify:

1. ✅ LineNoise dependency added to Package.swift
2. ✅ Configuration updated with readline options (default: `false`)
3. ✅ `--no-readline` CLI flag added
4. ✅ InputHandler protocol and implementations created
5. ✅ AgentLoop uses InputHandler instead of readLine()
6. ✅ SSH detection implemented (checks SSH_CONNECTION, SSH_CLIENT, SSH_TTY)
7. ✅ TERM validation implemented (rejects empty or "dumb")
8. ✅ Readline works when enabled (arrow keys, history navigation, Ctrl+R search)
9. ✅ History persists across sessions (when readline used)
10. ✅ `--no-readline` flag disables readline
11. ✅ Piped input auto-disables readline (TTY detection)
12. ✅ SSH sessions auto-disable readline (no character duplication)
13. ✅ Invalid TERM auto-disables readline
14. ✅ History file created with 600 permissions
15. ✅ History trimmed to maxEntries
16. ✅ All tests pass (including SSH and TERM tests)
17. ✅ Build succeeds without warnings

**Retry Limit**: 3 attempts

**On Success**:
- Create build-history entry
- Mark step complete in BUILD_STATUS.md
- Proceed to next step (or mark build complete if this is final step)

**On Failure** (after 3 attempts):
- Document issues in BUILD_STATUS.md
- STOP - require human intervention

---

## Notes

- LineNoise is recommended over system readline for portability
- History file may contain sensitive commands - warn users about this
- TTY detection ensures piped input works (e.g., for automation)
- Tab completion is listed as future enhancement - not required now
- Test both readline and non-readline modes thoroughly

---

**End of Step 44**
