# Step 000021: Sandboxing (sandbox-exec)

**GUID**: a1b2c3d4e5f6
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Run shell commands in macOS sandbox to prevent unauthorized system access.

**What This Step Does**:
- Wraps run_shell tool in sandbox-exec
- Defines sandbox profile (restrict filesystem access)
- Handles sandbox violations gracefully
- Prevents unauthorized access to sensitive paths

**Why This Step Exists**:
After Step 19, run_shell executes commands with full user privileges. This step locks down command execution using macOS sandbox-exec to prevent:
- Reading sensitive files (~/.ssh, ~/.aws)
- Writing to system directories
- Network access (unless explicitly allowed)
- Executing dangerous commands

**Dependencies**:
- ✅ Step 6: Error handling (YBSError for sandbox violations)
- ✅ Step 19: run_shell tool (what we're sandboxing)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Security Model (Sandboxing)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Use sandbox-exec for macOS

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 450-470 (Sandboxing section)
- `systems/bootstrap/docs/security-model.md` (Security layers)

---

## What to Build

### File Structure

```
Sources/YBS/Safety/
├── Sandbox.swift              # Sandbox execution wrapper
└── sandbox-profile.sb         # Sandbox profile definition
```

### 1. Sandbox.swift

**Purpose**: Wrap shell commands in sandbox-exec with restrictive profile.

**Key Components**:

```swift
public class Sandbox {
    /// Execute command in sandbox
    /// - Parameters:
    ///   - command: Shell command to execute
    ///   - workingDirectory: Allowed working directory
    ///   - timeout: Command timeout (seconds)
    /// - Returns: (stdout, stderr, exitCode)
    /// - Throws: YBSError.sandboxViolation if blocked
    public static func execute(
        command: String,
        in workingDirectory: String,
        timeout: TimeInterval
    ) async throws -> (String, String, Int32)

    /// Get path to sandbox profile
    private static func profilePath() -> String

    /// Build sandbox-exec command
    /// - Returns: Full command with sandbox-exec wrapper
    private static func buildSandboxCommand(
        _ command: String,
        workingDir: String
    ) -> String
}
```

**Implementation Details**:

1. **Sandbox Profile Loading**:
   - Load sandbox-profile.sb from bundle resources
   - Validate profile exists
   - Pass to sandbox-exec via -f flag

2. **Command Wrapping**:
   ```swift
   let sandboxCmd = """
       sandbox-exec -f \(profilePath) sh -c 'cd \(workingDir) && \(command)'
       """
   ```

3. **Execution**:
   - Use Process API (same as run_shell)
   - Capture stdout and stderr
   - Detect sandbox violations (specific error messages)
   - Timeout handling

4. **Error Detection**:
   - Exit code 1 + stderr contains "sandbox"
   - Throw YBSError.sandboxViolation with details
   - Include violated path/operation in error message

**Size**: ~100 lines

---

### 2. sandbox-profile.sb

**Purpose**: Define sandbox restrictions for command execution.

**Profile Contents**:

```scheme
(version 1)
(debug deny)

;; Default deny all operations
(deny default)

;; Allow reading from working directory
(allow file-read* (subpath (param "WORKDIR")))

;; Allow writing to working directory (but not hidden files)
(allow file-write*
    (subpath (param "WORKDIR"))
    (require-not (regex #"^\.")))

;; Allow reading common system files (needed for shell execution)
(allow file-read*
    (subpath "/usr/bin")
    (subpath "/usr/lib")
    (subpath "/bin")
    (subpath "/lib")
    (subpath "/System/Library"))

;; Allow executing binaries
(allow process-exec
    (subpath "/usr/bin")
    (subpath "/bin"))

;; Deny sensitive paths
(deny file-read* file-write*
    (subpath (string-append (param "HOME") "/.ssh"))
    (subpath (string-append (param "HOME") "/.aws"))
    (subpath (string-append (param "HOME") "/.config"))
    (literal (string-append (param "HOME") "/.bashrc"))
    (literal (string-append (param "HOME") "/.zshrc")))

;; Deny network access
(deny network*)

;; Allow standard streams (stdin/stdout/stderr)
(allow file-read* file-write*
    (literal "/dev/stdin")
    (literal "/dev/stdout")
    (literal "/dev/stderr"))
```

**Key Restrictions**:
- ✅ Read working directory
- ✅ Write to working directory (no hidden files)
- ✅ Execute common binaries (/bin, /usr/bin)
- ❌ Read ~/.ssh, ~/.aws, ~/.config
- ❌ Network access
- ❌ System directory writes

**Size**: ~50 lines

---

### 3. Integration with RunShellTool

**Update**: `Sources/YBS/Tools/RunShellTool.swift`

**Changes**:

```swift
public struct RunShellTool: Tool {
    // ... existing code ...

    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        let command = parameters["command"] as? String ?? ""
        let workingDir = parameters["working_directory"] as? String ?? FileManager.default.currentDirectoryPath
        let timeout = parameters["timeout"] as? TimeInterval ?? 30.0

        // Use sandbox if enabled in config
        let config = try ConfigLoader.load()

        let (stdout, stderr, exitCode) = if config.safety.useSandbox {
            try await Sandbox.execute(
                command: command,
                in: workingDir,
                timeout: timeout
            )
        } else {
            // Original unsandboxed execution (for testing)
            try await executeUnsandboxed(
                command: command,
                in: workingDir,
                timeout: timeout
            )
        }

        // ... rest of result handling ...
    }
}
```

**Config Addition** (BUILD_CONFIG.json):
```json
{
  "safety": {
    "useSandbox": true
  }
}
```

---

## Tests

**Location**: `Tests/YBSTests/Safety/SandboxTests.swift`

### Test Cases

**1. Basic Sandboxed Execution**:
```swift
func testSandboxAllowsReadInWorkdir() async throws {
    let result = try await Sandbox.execute(
        command: "ls -la",
        in: "/tmp/test",
        timeout: 5.0
    )
    XCTAssertEqual(result.2, 0) // Exit code 0
    XCTAssertTrue(result.0.contains(".")) // Contains files
}
```

**2. Blocked Path Access**:
```swift
func testSandboxBlocksSensitivePaths() async throws {
    do {
        _ = try await Sandbox.execute(
            command: "cat ~/.ssh/id_rsa",
            in: "/tmp",
            timeout: 5.0
        )
        XCTFail("Should have thrown sandboxViolation")
    } catch YBSError.sandboxViolation {
        // Expected
    }
}
```

**3. Write Protection**:
```swift
func testSandboxAllowsWriteInWorkdir() async throws {
    let result = try await Sandbox.execute(
        command: "echo 'test' > output.txt",
        in: "/tmp/test",
        timeout: 5.0
    )
    XCTAssertEqual(result.2, 0)
    XCTAssertTrue(FileManager.default.fileExists(atPath: "/tmp/test/output.txt"))
}
```

**4. Network Blocking**:
```swift
func testSandboxBlocksNetwork() async throws {
    do {
        _ = try await Sandbox.execute(
            command: "curl https://example.com",
            in: "/tmp",
            timeout: 5.0
        )
        XCTFail("Should have blocked network")
    } catch YBSError.sandboxViolation {
        // Expected
    }
}
```

**Total Tests**: ~6-8 tests

---

## Verification Steps

### 1. Manual Testing

**Test 1: Allowed Operations**:
```bash
cd systems/bootstrap/builds/test6
swift run ybs

You: Run 'ls -la' in the current directory
# Should execute successfully with sandbox
```

**Test 2: Blocked Sensitive Access**:
```bash
You: Run 'cat ~/.ssh/id_rsa'
AI: <calls run_shell>
Sandbox: Operation not permitted
Tool: Error (sandbox violation: ~/.ssh/id_rsa)
AI: I cannot access that file due to security restrictions
```

**Test 3: Write to Working Directory**:
```bash
You: Create a file test.txt with 'echo hello > test.txt'
# Should succeed (writing to working directory)
```

**Test 4: Network Blocking**:
```bash
You: Run 'curl https://example.com'
# Should fail with sandbox violation
```

### 2. Automated Testing

```bash
swift test --filter SandboxTests
# All tests should pass
```

### 3. Success Criteria

- ✅ Commands execute in sandbox-exec wrapper
- ✅ Read/write allowed in working directory
- ✅ Sensitive paths (~/.ssh, ~/.aws) blocked
- ✅ Network access blocked
- ✅ Sandbox violations throw YBSError.sandboxViolation
- ✅ Error messages include violated path/operation
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 6: YBSError.sandboxViolation error type
- Step 19: RunShellTool implementation

**Enables**:
- Step 22: Additional path validation
- Secure command execution throughout system

---

## Implementation Notes

### Sandbox Profile Parameters

**Pass parameters to sandbox-exec**:
```bash
sandbox-exec \
    -D WORKDIR=/tmp/test \
    -D HOME=/Users/scott \
    -f sandbox-profile.sb \
    sh -c 'cd /tmp/test && ls -la'
```

### Error Message Parsing

**Detect sandbox violations**:
```swift
if exitCode != 0 && stderr.contains("sandbox") {
    // Extract violated operation from stderr
    let operation = parseSandboxError(stderr)
    throw YBSError.sandboxViolation(operation: operation)
}
```

### Configuration Toggle

**Allow disabling sandbox for testing**:
- Config: `safety.useSandbox = false`
- Useful during development
- Should be true in production

### macOS Version Compatibility

**sandbox-exec availability**:
- Available on all macOS versions
- No runtime checks needed
- Profile syntax stable since macOS 10.5

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Security First**:
- ✅ Sandbox all external command execution
- ✅ Fail closed (deny by default, allow explicitly)
- ✅ Clear error messages for violations

**§ Testing Security**:
- Test both allowed and blocked operations
- Test edge cases (hidden files, symlinks)
- Verify error messages are user-friendly

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] Sandbox.swift with execute() method
   - [ ] sandbox-profile.sb with restrictive profile
   - [ ] RunShellTool integration

2. **Tests Pass**:
   - [ ] All SandboxTests pass
   - [ ] Allowed operations work
   - [ ] Blocked operations fail correctly

3. **Verification Complete**:
   - [ ] Manual testing shows sandbox enforcement
   - [ ] Sensitive paths blocked
   - [ ] Working directory access allowed

4. **Documentation Updated**:
   - [ ] Code comments explain sandbox behavior
   - [ ] Profile comments explain each rule

**Estimated Time**: 2-3 hours
**Estimated Size**: ~150 lines (100 Swift + 50 profile)

---

## Next Steps

**After This Step**:
→ **Step 22**: Path Validation & Blocked Commands (additional safety layers)

**What It Enables**:
- Secure command execution
- Protection against AI-generated dangerous commands
- User trust in system safety

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
