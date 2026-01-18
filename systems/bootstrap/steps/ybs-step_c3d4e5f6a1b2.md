# Step 000023: External Tool Protocol

**GUID**: c3d4e5f6a1b2
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Enable execution of external binaries as tools through a standardized JSON protocol.

**What This Step Does**:
- Defines protocol for external tool execution
- Invokes external executables with JSON parameters
- Reads JSON results from stdout
- Handles timeouts and errors
- Validates tool schemas

**Why This Step Exists**:
Built-in tools (Steps 8-9, 16-19) provide core functionality, but users need extensibility:
- Add custom tools without modifying YBS
- Reuse existing scripts as tools
- Support language-specific tools (Python, Ruby, etc.)
- Community-contributed tools

**Dependencies**:
- ✅ Step 6: Error handling (YBSError.externalToolFailed)
- ✅ Step 10: Tool protocol and executor
- ✅ Step 19: Process execution (similar pattern)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § External Tools
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § JSON-based tool protocol

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 520-560 (External tools)
- `systems/bootstrap/docs/tool-architecture.md` (Hybrid tool system)

---

## External Tool Protocol

### Protocol Overview

**Communication**:
1. YBS → Tool: JSON parameters via stdin
2. Tool → YBS: JSON result via stdout
3. Tool → YBS: Errors via stderr

**Tool Invocation**:
```bash
echo '{"param1": "value1"}' | /path/to/tool
```

**Tool Response (Success)**:
```json
{
  "success": true,
  "result": "Operation completed",
  "metadata": {
    "executionTime": 1.23
  }
}
```

**Tool Response (Failure)**:
```json
{
  "success": false,
  "error": "Failed to process: file not found"
}
```

**Tool Schema** (via `--schema` flag):
```bash
/path/to/tool --schema
```

```json
{
  "name": "web_search",
  "description": "Search the web and return results",
  "parameters": {
    "query": {
      "type": "string",
      "description": "Search query",
      "required": true
    },
    "maxResults": {
      "type": "integer",
      "description": "Maximum results to return",
      "required": false,
      "default": 10
    }
  }
}
```

---

## What to Build

### File Structure

```
Sources/YBS/Tools/
├── ExternalTool.swift         # External tool executor
└── ExternalToolSchema.swift   # Schema types
```

### 1. ExternalTool.swift

**Purpose**: Execute external binaries as tools.

**Key Components**:

```swift
public struct ExternalTool: Tool {
    public let name: String
    public let executablePath: String
    public let schema: ExternalToolSchema
    public let timeout: TimeInterval

    public init(
        name: String,
        executablePath: String,
        schema: ExternalToolSchema,
        timeout: TimeInterval = 30.0
    )

    /// Execute external tool with parameters
    public func execute(parameters: [String: Any]) async throws -> ToolResult

    /// Invoke external tool process
    private func invokeProcess(
        with jsonInput: String
    ) async throws -> (stdout: String, stderr: String, exitCode: Int32)

    /// Parse JSON response from tool
    private func parseResponse(_ json: String) throws -> ToolResult

    /// Validate parameters against schema
    private func validateParameters(_ params: [String: Any]) throws
}
```

**Implementation Details**:

1. **Parameter Validation**:
   ```swift
   func validateParameters(_ params: [String: Any]) throws {
       for (key, paramSchema) in schema.parameters {
           if paramSchema.required && params[key] == nil {
               throw YBSError.missingParameter(name: key)
           }
           // Type checking
           if let value = params[key] {
               try validateType(value, expected: paramSchema.type)
           }
       }
   }
   ```

2. **Process Invocation**:
   ```swift
   func invokeProcess(with jsonInput: String) async throws -> (String, String, Int32) {
       let process = Process()
       process.executableURL = URL(fileURLWithPath: executablePath)

       let stdin = Pipe()
       let stdout = Pipe()
       let stderr = Pipe()

       process.standardInput = stdin
       process.standardOutput = stdout
       process.standardError = stderr

       // Write JSON to stdin
       try stdin.fileHandleForWriting.write(contentsOf: jsonInput.data(using: .utf8)!)
       try stdin.fileHandleForWriting.close()

       // Start process with timeout
       try process.run()

       // Wait with timeout
       let finished = await withTimeout(timeout) {
           process.waitUntilExit()
       }

       if !finished {
           process.terminate()
           throw YBSError.externalToolTimeout(name: name)
       }

       // Read output
       let stdoutData = try stdout.fileHandleForReading.readToEnd() ?? Data()
       let stderrData = try stderr.fileHandleForReading.readToEnd() ?? Data()

       return (
           String(data: stdoutData, encoding: .utf8) ?? "",
           String(data: stderrData, encoding: .utf8) ?? "",
           process.terminationStatus
       )
   }
   ```

3. **Response Parsing**:
   ```swift
   func parseResponse(_ json: String) throws -> ToolResult {
       guard let data = json.data(using: .utf8) else {
           throw YBSError.invalidToolResponse(message: "Not UTF-8")
       }

       let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)

       if response.success {
           return .success(response.result ?? "")
       } else {
           return .failure(response.error ?? "Unknown error")
       }
   }
   ```

4. **Timeout Handling**:
   ```swift
   func withTimeout<T>(
       _ timeout: TimeInterval,
       operation: @escaping () async -> T
   ) async -> T? {
       await withThrowingTaskGroup(of: T?.self) { group in
           group.addTask {
               await operation()
           }
           group.addTask {
               try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
               return nil
           }
           let result = try await group.next()
           group.cancelAll()
           return result ?? nil
       }
   }
   ```

**Size**: ~150 lines

---

### 2. ExternalToolSchema.swift

**Purpose**: Type definitions for external tool schemas.

**Key Components**:

```swift
/// External tool schema (from --schema)
public struct ExternalToolSchema: Codable {
    public let name: String
    public let description: String
    public let parameters: [String: ParameterSchema]
}

/// Parameter schema
public struct ParameterSchema: Codable {
    public let type: ParameterType
    public let description: String
    public let required: Bool
    public let defaultValue: Any?

    enum CodingKeys: String, CodingKey {
        case type, description, required
        case defaultValue = "default"
    }
}

/// Parameter types
public enum ParameterType: String, Codable {
    case string
    case integer
    case number
    case boolean
    case array
    case object
}

/// Tool response format
public struct ExternalToolResponse: Codable {
    public let success: Bool
    public let result: String?
    public let error: String?
    public let metadata: [String: String]?
}
```

**Size**: ~80 lines

---

### 3. Schema Loading

**Purpose**: Load tool schema from executable.

**Implementation**:

```swift
extension ExternalTool {
    /// Load schema by invoking tool with --schema
    public static func loadSchema(
        from executablePath: String
    ) async throws -> ExternalToolSchema {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = ["--schema"]

        let stdout = Pipe()
        process.standardOutput = stdout

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw YBSError.schemaLoadFailed(path: executablePath)
        }

        let data = try stdout.fileHandleForReading.readToEnd() ?? Data()
        let json = String(data: data, encoding: .utf8) ?? ""

        return try JSONDecoder().decode(ExternalToolSchema.self, from: data)
    }
}
```

---

## Example External Tool

**Location**: `examples/external-tools/echo-tool`

**Purpose**: Demonstration tool that echoes parameters.

```bash
#!/usr/bin/env python3
import json
import sys

def main():
    # Read parameters from stdin
    params = json.loads(sys.stdin.read())

    # Process
    message = params.get("message", "")

    # Return result
    result = {
        "success": True,
        "result": f"Echo: {message}",
        "metadata": {
            "length": len(message)
        }
    }

    print(json.dumps(result))

if __name__ == "__main__":
    if "--schema" in sys.argv:
        schema = {
            "name": "echo",
            "description": "Echo a message back",
            "parameters": {
                "message": {
                    "type": "string",
                    "description": "Message to echo",
                    "required": True
                }
            }
        }
        print(json.dumps(schema))
    else:
        main()
```

**Make executable**:
```bash
chmod +x examples/external-tools/echo-tool
```

---

## Tests

**Location**: `Tests/YBSTests/Tools/ExternalToolTests.swift`

### Test Cases

**1. Basic Execution**:
```swift
func testExternalToolExecution() async throws {
    let tool = ExternalTool(
        name: "echo",
        executablePath: "/path/to/echo-tool",
        schema: echoSchema
    )

    let result = try await tool.execute(parameters: [
        "message": "Hello World"
    ])

    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(result.content, "Echo: Hello World")
}
```

**2. Schema Loading**:
```swift
func testSchemaLoading() async throws {
    let schema = try await ExternalTool.loadSchema(
        from: "/path/to/echo-tool"
    )

    XCTAssertEqual(schema.name, "echo")
    XCTAssertTrue(schema.parameters["message"]?.required == true)
}
```

**3. Timeout Handling**:
```swift
func testExternalToolTimeout() async throws {
    let tool = ExternalTool(
        name: "slow-tool",
        executablePath: "/path/to/slow-tool",
        schema: slowSchema,
        timeout: 1.0
    )

    do {
        _ = try await tool.execute(parameters: [:])
        XCTFail("Should have timed out")
    } catch YBSError.externalToolTimeout {
        // Expected
    }
}
```

**4. Error Handling**:
```swift
func testExternalToolError() async throws {
    let tool = ExternalTool(
        name: "failing-tool",
        executablePath: "/path/to/failing-tool",
        schema: failSchema
    )

    let result = try await tool.execute(parameters: [:])

    XCTAssertFalse(result.isSuccess)
    XCTAssertTrue(result.content.contains("error"))
}
```

**5. Parameter Validation**:
```swift
func testParameterValidation() async throws {
    let tool = ExternalTool(
        name: "echo",
        executablePath: "/path/to/echo-tool",
        schema: echoSchema
    )

    do {
        // Missing required parameter
        _ = try await tool.execute(parameters: [:])
        XCTFail("Should have thrown missing parameter")
    } catch YBSError.missingParameter {
        // Expected
    }
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Create Test Tool

```bash
cd systems/bootstrap/builds/test6
mkdir -p examples/external-tools

cat > examples/external-tools/web-search << 'EOF'
#!/usr/bin/env python3
import json
import sys

if "--schema" in sys.argv:
    print(json.dumps({
        "name": "web_search",
        "description": "Search the web (mock)",
        "parameters": {
            "query": {"type": "string", "description": "Search query", "required": True}
        }
    }))
else:
    params = json.loads(sys.stdin.read())
    result = {
        "success": True,
        "result": f"Search results for: {params['query']}"
    }
    print(json.dumps(result))
EOF

chmod +x examples/external-tools/web-search
```

### 2. Manual Testing

```bash
swift test --filter ExternalToolTests
# All tests pass

# Test echo-tool directly
echo '{"message": "Hello"}' | examples/external-tools/echo-tool
# Should output: {"success": true, "result": "Echo: Hello", ...}

# Test schema loading
examples/external-tools/echo-tool --schema
# Should output tool schema JSON
```

### 3. Integration Test

**Test external tool from agent**:
```bash
swift run ybs

# After implementing tool discovery in Step 24:
You: Use the web-search tool to search for "Swift async await"
AI: <calls web_search tool>
Tool: Search results for: Swift async await
AI: I found results for Swift async await...
```

### 4. Success Criteria

- ✅ External tools execute with JSON I/O
- ✅ Schema loading works via --schema flag
- ✅ Timeouts enforced (kills hanging tools)
- ✅ Parameter validation against schema
- ✅ Success and failure responses handled
- ✅ Stderr captured for debugging
- ✅ All tests pass

---

## Configuration

**No config changes needed** for this step.

**Tool discovery** (Step 24) will add:
```json
{
  "externalTools": {
    "searchPaths": [
      "~/.ybs/tools",
      "./tools"
    ]
  }
}
```

---

## Dependencies

**Requires**:
- Step 6: Error types (externalToolFailed, externalToolTimeout)
- Step 10: Tool protocol
- Step 19: Process execution pattern

**Enables**:
- Step 24: Tool discovery and auto-loading
- Extensible tool system
- Community tools

---

## Implementation Notes

### Security Considerations

**Execute external tools with caution**:
1. Validate executable path (no shell injection)
2. Timeout enforcement (prevent hanging)
3. Stdin/stdout/stderr isolation
4. Consider sandboxing (future enhancement)

**Path validation**:
```swift
guard FileManager.default.isExecutableFile(atPath: executablePath) else {
    throw YBSError.toolNotExecutable(path: executablePath)
}
```

### JSON Parsing Robustness

**Handle malformed JSON**:
```swift
do {
    return try JSONDecoder().decode(ExternalToolResponse.self, from: data)
} catch {
    // Try to extract error from stderr
    if !stderr.isEmpty {
        return .failure(stderr)
    }
    throw YBSError.invalidToolResponse(message: error.localizedDescription)
}
```

### Language Support

**Tools can be written in any language**:
- Python: `#!/usr/bin/env python3`
- Ruby: `#!/usr/bin/env ruby`
- Node.js: `#!/usr/bin/env node`
- Bash: `#!/bin/bash`
- Go: Compiled binary
- Rust: Compiled binary

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Extensibility**:
- ✅ Simple JSON protocol (easy to implement)
- ✅ Language-agnostic (any language works)
- ✅ Clear error handling

**§ Testing**:
- ✅ Test with multiple tool types
- ✅ Test timeout edge cases
- ✅ Test malformed responses

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ExternalTool.swift with execution logic
   - [ ] ExternalToolSchema.swift with types
   - [ ] Schema loading functionality
   - [ ] Example echo-tool

2. **Tests Pass**:
   - [ ] All ExternalToolTests pass
   - [ ] Execution works
   - [ ] Timeouts enforced
   - [ ] Error handling works

3. **Verification Complete**:
   - [ ] Example tools execute successfully
   - [ ] Schema loading works
   - [ ] JSON I/O validated

4. **Documentation Updated**:
   - [ ] Protocol documented in code comments
   - [ ] Example tools provided

**Estimated Time**: 3-4 hours
**Estimated Size**: ~230 lines + examples

---

## Next Steps

**After This Step**:
→ **Step 24**: External Tool Discovery & Loading (auto-discovery)

**What It Enables**:
- Extensible tool system
- User-created tools
- Community-contributed tools

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
