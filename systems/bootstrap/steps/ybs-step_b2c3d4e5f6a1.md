# Step 000022: Path Validation & Blocked Commands

**GUID**: b2c3d4e5f6a1
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Additional safety layer to validate paths and block dangerous commands before execution.

**What This Step Does**:
- Validates file paths are within allowed directories
- Blocks access to sensitive paths (~/.ssh, ~/.aws, ~/.config)
- Blocks dangerous shell commands (rm -rf /, sudo, chmod 777)
- Provides whitelist/blacklist configuration

**Why This Step Exists**:
Sandbox-exec (Step 21) provides OS-level protection, but:
- Not all operations need sandbox (file read/write tools)
- Better UX to block early with clear error messages
- Allows configuration of blocked paths/commands
- Defense-in-depth strategy

**Dependencies**:
- ✅ Step 4: Configuration loading (for blocked lists)
- ✅ Step 6: Error handling (YBSError.pathBlocked, commandBlocked)
- ✅ Step 19: run_shell tool (command validation)
- ✅ Step 21: Sandbox (used together)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Security Model (Path Validation)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Defense-in-depth security

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 471-490 (Path validation)
- `systems/bootstrap/docs/security-model.md` (Security layers)

---

## What to Build

### File Structure

```
Sources/YBS/Safety/
├── PathValidator.swift        # Path validation logic
├── CommandValidator.swift     # Command blocking logic
└── BlockedLists.swift         # Default blocked paths/commands
```

### 1. PathValidator.swift

**Purpose**: Validate file paths before tool execution.

**Key Components**:

```swift
public class PathValidator {
    private let config: SafetyConfig

    public init(config: SafetyConfig) {
        self.config = config
    }

    /// Validate path is allowed for operation
    /// - Parameters:
    ///   - path: File path to validate
    ///   - operation: read, write, or execute
    /// - Throws: YBSError.pathBlocked if not allowed
    public func validate(path: String, for operation: FileOperation) throws

    /// Check if path is in allowed directory
    /// - Returns: true if path is within allowed directories
    private func isInAllowedDirectory(_ path: String) -> Bool

    /// Check if path matches blocked patterns
    /// - Returns: true if path should be blocked
    private func matchesBlockedPattern(_ path: String) -> Bool

    /// Resolve symlinks and relative paths
    /// - Returns: Canonical absolute path
    private func canonicalize(_ path: String) throws -> String
}

public enum FileOperation {
    case read
    case write
    case execute
}
```

**Implementation Details**:

1. **Path Canonicalization**:
   ```swift
   let canonicalPath = try FileManager.default
       .url(fileURLWithPath: path)
       .resolvingSymlinksInPath()
       .path
   ```

2. **Allowed Directory Check**:
   ```swift
   let allowedDirs = [
       config.workingDirectory,
       "/tmp",
       "/var/tmp"
   ]
   return allowedDirs.contains { canonicalPath.hasPrefix($0) }
   ```

3. **Blocked Patterns**:
   ```swift
   let blockedPatterns = [
       "~/.ssh",
       "~/.aws",
       "~/.config",
       "~/.gnupg",
       "/etc",
       "/System",
       "/Library/System"
   ]
   return blockedPatterns.contains {
       canonicalPath.contains(expandTilde($0))
   }
   ```

4. **Symlink Prevention**:
   - Resolve all symlinks before validation
   - Prevents escaping via symlinks

**Size**: ~80 lines

---

### 2. CommandValidator.swift

**Purpose**: Validate shell commands before execution.

**Key Components**:

```swift
public class CommandValidator {
    private let config: SafetyConfig

    public init(config: SafetyConfig) {
        self.config = config
    }

    /// Validate command is safe to execute
    /// - Throws: YBSError.commandBlocked if command blocked
    public func validate(command: String) throws

    /// Check if command contains blocked keywords
    private func containsBlockedKeywords(_ command: String) -> Bool

    /// Check if command uses dangerous flags
    private func containsDangerousFlags(_ command: String) -> Bool

    /// Extract command name from command string
    private func extractCommandName(_ command: String) -> String
}
```

**Implementation Details**:

1. **Blocked Commands**:
   ```swift
   let blockedCommands = [
       "sudo",
       "su",
       "doas",
       "chmod 777",
       "chmod -R 777",
       "rm -rf /",
       "rm -rf ~",
       "rm -rf *",
       "mkfs",
       "dd if=/dev/random",
       ":(){ :|:& };:",  // Fork bomb
   ]
   ```

2. **Dangerous Flags**:
   ```swift
   let dangerousFlags = [
       "--no-preserve-root",
       "-rf /",
       "-rf ~",
       "--force --recursive"
   ]
   ```

3. **Command Parsing**:
   ```swift
   // Extract first word (command name)
   let parts = command.split(separator: " ")
   let commandName = parts.first?.lowercased() ?? ""

   // Check against blocked list
   if config.blockedCommands.contains(commandName) {
       throw YBSError.commandBlocked(command: commandName)
   }
   ```

4. **Pattern Matching**:
   - Regex patterns for complex cases
   - Case-insensitive matching
   - Handle quoted arguments

**Size**: ~100 lines

---

### 3. BlockedLists.swift

**Purpose**: Default blocked paths and commands.

**Key Components**:

```swift
public struct BlockedLists {
    /// Default blocked paths (home directory relative)
    public static let defaultBlockedPaths: [String] = [
        ".ssh",
        ".aws",
        ".config",
        ".gnupg",
        ".kube",
        ".docker",
        ".env",
        ".bashrc",
        ".zshrc",
        ".bash_history",
        ".zsh_history"
    ]

    /// Default blocked system paths
    public static let defaultBlockedSystemPaths: [String] = [
        "/etc",
        "/System",
        "/Library/System",
        "/usr/bin/sudo",
        "/usr/sbin",
        "/private/etc"
    ]

    /// Default blocked commands
    public static let defaultBlockedCommands: [String] = [
        "sudo",
        "su",
        "doas",
        "chmod",  // Require explicit allow
        "chown",
        "chgrp",
        "rm",     // Require explicit allow
        "mkfs",
        "dd",
        "fdisk",
        "diskutil"
    ]

    /// Commands that require confirmation (not fully blocked)
    public static let confirmationRequired: [String] = [
        "rm",
        "mv",
        "chmod",
        "git push --force",
        "git reset --hard",
        "npm publish",
        "cargo publish"
    ]
}
```

**Size**: ~50 lines

---

### 4. Integration with Tools

**Update RunShellTool**:
```swift
public func execute(parameters: [String: Any]) async throws -> ToolResult {
    let command = parameters["command"] as? String ?? ""

    // Validate command before execution
    let validator = CommandValidator(config: config)
    try validator.validate(command: command)

    // Then execute (with sandbox)
    let result = try await Sandbox.execute(...)
    return result
}
```

**Update File Tools** (read_file, write_file, edit_file):
```swift
public func execute(parameters: [String: Any]) async throws -> ToolResult {
    let path = parameters["path"] as? String ?? ""

    // Validate path
    let validator = PathValidator(config: config)
    try validator.validate(path: path, for: .read)  // or .write

    // Then execute operation
    let content = try String(contentsOfFile: path)
    return ToolResult.success(content)
}
```

---

## Tests

**Location**: `Tests/YBSTests/Safety/ValidationTests.swift`

### Test Cases

**Path Validation Tests**:

```swift
func testAllowsWorkingDirectory() throws {
    let validator = PathValidator(config: testConfig)
    XCTAssertNoThrow(
        try validator.validate(path: "/tmp/test/file.txt", for: .read)
    )
}

func testBlocksSensitivePaths() throws {
    let validator = PathValidator(config: testConfig)
    XCTAssertThrowsError(
        try validator.validate(path: "~/.ssh/id_rsa", for: .read)
    ) { error in
        XCTAssertTrue(error is YBSError.PathBlocked)
    }
}

func testResolvesSymlinks() throws {
    // Create symlink to ~/.ssh
    let linkPath = "/tmp/test/link"
    try! FileManager.default.createSymbolicLink(
        atPath: linkPath,
        withDestinationPath: "\(NSHomeDirectory())/.ssh"
    )

    let validator = PathValidator(config: testConfig)
    XCTAssertThrowsError(
        try validator.validate(path: linkPath, for: .read)
    )
}
```

**Command Validation Tests**:

```swift
func testBlocksSudo() throws {
    let validator = CommandValidator(config: testConfig)
    XCTAssertThrowsError(
        try validator.validate(command: "sudo rm -rf /tmp/test")
    ) { error in
        XCTAssertTrue(error is YBSError.CommandBlocked)
    }
}

func testBlocksDangerousRm() throws {
    let validator = CommandValidator(config: testConfig)
    let dangerousCommands = [
        "rm -rf /",
        "rm -rf ~",
        "rm -rf *"
    ]

    for cmd in dangerousCommands {
        XCTAssertThrowsError(try validator.validate(command: cmd))
    }
}

func testAllowsSafeCommands() throws {
    let validator = CommandValidator(config: testConfig)
    XCTAssertNoThrow(
        try validator.validate(command: "ls -la")
    )
    XCTAssertNoThrow(
        try validator.validate(command: "cat file.txt")
    )
}
```

**Total Tests**: ~10-12 tests

---

## Verification Steps

### 1. Manual Testing

**Test 1: Blocked Path**:
```bash
cd systems/bootstrap/builds/test6
swift run ybs

You: Read the file ~/.ssh/id_rsa
AI: <calls read_file>
Validator: Path blocked (sensitive path: ~/.ssh/id_rsa)
Tool: Error
AI: I cannot read that file - it's in a blocked directory (~/.ssh)
```

**Test 2: Blocked Command**:
```bash
You: Run 'sudo apt install something'
AI: <calls run_shell>
Validator: Command blocked (dangerous command: sudo)
Tool: Error
AI: I cannot execute sudo commands for security reasons
```

**Test 3: Allowed Operations**:
```bash
You: Read Package.swift
# Should work (working directory)

You: List files in Sources/
# Should work (working directory)
```

### 2. Automated Testing

```bash
swift test --filter ValidationTests
# All tests should pass
```

### 3. Success Criteria

- ✅ Sensitive paths blocked (~/.ssh, ~/.aws)
- ✅ Dangerous commands blocked (sudo, rm -rf /)
- ✅ Symlinks resolved before validation
- ✅ Clear error messages explain why blocked
- ✅ Working directory operations allowed
- ✅ All tests pass

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "safety": {
    "useSandbox": true,
    "blockedPaths": [
      "~/.ssh",
      "~/.aws",
      "~/.config"
    ],
    "allowedDirectories": [
      "{{WORKING_DIR}}",
      "/tmp",
      "/var/tmp"
    ],
    "blockedCommands": [
      "sudo",
      "su",
      "rm -rf /",
      "chmod 777"
    ]
  }
}
```

**Customization**:
- Users can add custom blocked paths
- Users can allow specific commands
- Per-project configuration

---

## Dependencies

**Requires**:
- Step 4: Configuration loading
- Step 6: YBSError types
- Step 19: run_shell tool
- Step 21: Sandbox (complementary)

**Enables**:
- Comprehensive security model
- User-configurable safety
- Clear security error messages

---

## Implementation Notes

### Defense-in-Depth Strategy

**Layer 1: Path/Command Validation** (this step)
- Fast, early rejection
- Clear error messages
- User-configurable

**Layer 2: Sandbox** (Step 21)
- OS-level enforcement
- Catches validation bypasses
- Always-on protection

**Together**: Maximum security + good UX

### Tilde Expansion

```swift
func expandTilde(_ path: String) -> String {
    if path.hasPrefix("~") {
        return path.replacingOccurrences(
            of: "~",
            with: FileManager.default.homeDirectoryForCurrentUser.path
        )
    }
    return path
}
```

### Regex Patterns

**For complex command detection**:
```swift
let rmRfPattern = #"rm\s+(-[a-z]*r[a-z]*f[a-z]*|--recursive\s+--force)\s+/"#
let regex = try NSRegularExpression(pattern: rmRfPattern)
```

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Security First**:
- ✅ Multiple layers of protection
- ✅ Fail closed (block unknown patterns)
- ✅ User-configurable but safe defaults

**§ Error Messages**:
- ✅ Explain WHY operation blocked
- ✅ Suggest alternatives when possible

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] PathValidator.swift with validation logic
   - [ ] CommandValidator.swift with command checking
   - [ ] BlockedLists.swift with defaults
   - [ ] Tool integrations (read/write/shell)

2. **Tests Pass**:
   - [ ] All ValidationTests pass
   - [ ] Blocked paths rejected
   - [ ] Blocked commands rejected
   - [ ] Allowed operations work

3. **Verification Complete**:
   - [ ] Manual testing shows validation working
   - [ ] Symlinks handled correctly
   - [ ] Error messages clear

4. **Documentation Updated**:
   - [ ] Code comments explain validation rules
   - [ ] Config documentation updated

**Estimated Time**: 2-3 hours
**Estimated Size**: ~230 lines total

---

## Next Steps

**After This Step**:
→ **Step 23**: External Tool Protocol (plugin system)

**What It Enables**:
- Comprehensive security model complete
- User trust in system safety
- Foundation for tool expansion

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
