# Step 000024: External Tool Discovery & Loading

**GUID**: d4e5f6a1b2c3
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Automatically discover and load external tools from configured directories.

**What This Step Does**:
- Scans configured directories for executable files
- Loads tool schemas via --schema flag
- Registers discovered tools with ToolExecutor
- Validates tool schemas
- Handles tool loading errors gracefully

**Why This Step Exists**:
After Step 23, external tools can be executed, but must be registered manually. This step adds auto-discovery:
- Drop tool in ~/.ybs/tools/ and it's available
- No configuration required (zero-config experience)
- Tools can be added/removed without restarting
- List available tools with --list-tools

**Dependencies**:
- ✅ Step 4: Configuration (tool search paths)
- ✅ Step 6: Error handling (toolLoadFailed)
- ✅ Step 10: ToolExecutor (registration)
- ✅ Step 23: ExternalTool protocol

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Tool Discovery
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Auto-discovery for extensibility

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 561-590 (Tool discovery)
- `systems/bootstrap/docs/tool-architecture.md` (Tool system design)

---

## What to Build

### File Structure

```
Sources/YBS/Tools/
├── ToolDiscovery.swift        # Discovery and loading
└── ToolRegistry.swift         # Central tool registry
```

### 1. ToolDiscovery.swift

**Purpose**: Discover and load external tools from filesystem.

**Key Components**:

```swift
public class ToolDiscovery {
    private let config: Config
    private let registry: ToolRegistry

    public init(config: Config, registry: ToolRegistry) {
        self.config = config
        self.registry = registry
    }

    /// Discover and load all external tools
    /// - Returns: Number of tools loaded
    @discardableResult
    public func discoverAndLoadTools() async -> Int

    /// Scan directory for executable files
    /// - Returns: List of executable paths
    private func scanDirectory(_ path: String) -> [String]

    /// Check if file is executable
    private func isExecutable(_ path: String) -> Bool

    /// Load single tool from path
    /// - Returns: ExternalTool if successful, nil if failed
    private func loadTool(from path: String) async -> ExternalTool?

    /// Extract tool name from executable path
    /// - Returns: Tool name (filename without extension)
    private func extractToolName(from path: String) -> String
}
```

**Implementation Details**:

1. **Directory Scanning**:
   ```swift
   func scanDirectory(_ path: String) -> [String] {
       let expandedPath = (path as NSString).expandingTildeInPath
       let fileManager = FileManager.default

       guard let enumerator = fileManager.enumerator(atPath: expandedPath) else {
           return []
       }

       var executables: [String] = []

       for case let filename as String in enumerator {
           let fullPath = (expandedPath as NSString).appendingPathComponent(filename)

           // Skip hidden files and directories
           if filename.hasPrefix(".") {
               continue
           }

           // Check if executable
           if isExecutable(fullPath) {
               executables.append(fullPath)
           }
       }

       return executables
   }
   ```

2. **Executable Check**:
   ```swift
   func isExecutable(_ path: String) -> Bool {
       let fileManager = FileManager.default

       // Check file exists
       guard fileManager.fileExists(atPath: path) else {
           return false
       }

       // Check executable bit
       guard fileManager.isExecutableFile(atPath: path) else {
           return false
       }

       // Check not a directory
       var isDirectory: ObjCBool = false
       fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
       guard !isDirectory.boolValue else {
           return false
       }

       return true
   }
   ```

3. **Tool Loading**:
   ```swift
   func loadTool(from path: String) async -> ExternalTool? {
       do {
           // Load schema
           let schema = try await ExternalTool.loadSchema(from: path)

           // Create tool
           let tool = ExternalTool(
               name: schema.name,
               executablePath: path,
               schema: schema,
               timeout: config.externalTools.defaultTimeout
           )

           return tool

       } catch {
           Logger.warning("Failed to load tool from \(path): \(error)")
           return nil
       }
   }
   ```

4. **Discovery Process**:
   ```swift
   func discoverAndLoadTools() async -> Int {
       var loadedCount = 0

       // Scan each configured search path
       for searchPath in config.externalTools.searchPaths {
           Logger.info("Scanning for tools in: \(searchPath)")

           let executables = scanDirectory(searchPath)
           Logger.debug("Found \(executables.count) executables")

           // Load each tool
           for executablePath in executables {
               if let tool = await loadTool(from: executablePath) {
                   registry.register(tool)
                   loadedCount += 1
                   Logger.info("Loaded external tool: \(tool.name)")
               }
           }
       }

       return loadedCount
   }
   ```

5. **Tool Name Extraction**:
   ```swift
   func extractToolName(from path: String) -> String {
       let filename = (path as NSString).lastPathComponent

       // Remove extension if present
       if let dotIndex = filename.lastIndex(of: ".") {
           return String(filename[..<dotIndex])
       }

       return filename
   }
   ```

**Size**: ~120 lines

---

### 2. ToolRegistry.swift

**Purpose**: Central registry for all tools (built-in + external).

**Key Components**:

```swift
public class ToolRegistry {
    private var tools: [String: Tool] = [:]
    private let lock = NSLock()

    /// Register a tool
    public func register(_ tool: Tool) {
        lock.withLock {
            tools[tool.name] = tool
        }
    }

    /// Get tool by name
    /// - Returns: Tool if registered, nil otherwise
    public func tool(named name: String) -> Tool? {
        lock.withLock {
            tools[name]
        }
    }

    /// Get all registered tool names
    public func allToolNames() -> [String] {
        lock.withLock {
            Array(tools.keys).sorted()
        }
    }

    /// Get all registered tools
    public func allTools() -> [Tool] {
        lock.withLock {
            Array(tools.values)
        }
    }

    /// Check if tool is registered
    public func hasToolNamed(_ name: String) -> Bool {
        lock.withLock {
            tools[name] != nil
        }
    }

    /// Unregister tool
    public func unregister(named name: String) {
        lock.withLock {
            tools.removeValue(forKey: name)
        }
    }

    /// Clear all tools
    public func clear() {
        lock.withLock {
            tools.removeAll()
        }
    }
}
```

**Thread Safety**:
- NSLock for concurrent access
- Safe for use from multiple tasks

**Size**: ~80 lines

---

### 3. Integration with Main

**Update**: `Sources/YBS/main.swift` (or wherever initialization happens)

```swift
@main
struct YBS {
    static func main() async throws {
        // Load config
        let config = try ConfigLoader.load()

        // Create tool registry
        let registry = ToolRegistry()

        // Register built-in tools
        registry.register(ReadFileTool())
        registry.register(WriteFileTool())
        registry.register(EditFileTool())
        registry.register(ListFilesTool())
        registry.register(SearchFilesTool())
        registry.register(RunShellTool())

        // Discover and load external tools
        let discovery = ToolDiscovery(config: config, registry: registry)
        let externalToolCount = await discovery.discoverAndLoadTools()

        Logger.info("Loaded \(externalToolCount) external tools")
        Logger.info("Total tools available: \(registry.allToolNames().count)")

        // Create tool executor
        let executor = ToolExecutor(registry: registry)

        // Start agent
        let agent = Agent(config: config, executor: executor)
        try await agent.run()
    }
}
```

---

### 4. CLI Integration

**Add --list-tools flag**:

```swift
extension YBSCommand {
    @Flag(name: .long, help: "List all available tools")
    var listTools: Bool = false

    mutating func run() async throws {
        if listTools {
            try await listAvailableTools()
            return
        }

        // Normal execution
        // ...
    }

    func listAvailableTools() async throws {
        let config = try ConfigLoader.load()
        let registry = ToolRegistry()

        // Load all tools
        registerBuiltInTools(registry)
        let discovery = ToolDiscovery(config: config, registry: registry)
        await discovery.discoverAndLoadTools()

        // Print tool list
        print("Available Tools:")
        print()

        for toolName in registry.allToolNames() {
            guard let tool = registry.tool(named: toolName) else { continue }

            let type = tool is ExternalTool ? "external" : "built-in"
            print("  \(toolName) (\(type))")

            if let externalTool = tool as? ExternalTool {
                print("    \(externalTool.schema.description)")
                print("    Path: \(externalTool.executablePath)")
            }

            print()
        }
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "externalTools": {
    "searchPaths": [
      "~/.ybs/tools",
      "./tools",
      "./.ybs/tools"
    ],
    "defaultTimeout": 30.0,
    "enabled": true
  }
}
```

**Configuration Options**:
- `searchPaths`: Directories to scan for tools
- `defaultTimeout`: Default timeout for external tools
- `enabled`: Enable/disable external tool discovery

---

## Tests

**Location**: `Tests/YBSTests/Tools/ToolDiscoveryTests.swift`

### Test Cases

**1. Discover Tools**:
```swift
func testDiscoverTools() async throws {
    // Create test tool directory
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    // Create test tool
    let toolPath = tempDir.appendingPathComponent("test-tool")
    try createMockTool(at: toolPath.path)

    // Configure search path
    var config = Config.default
    config.externalTools.searchPaths = [tempDir.path]

    // Discover tools
    let registry = ToolRegistry()
    let discovery = ToolDiscovery(config: config, registry: registry)
    let count = await discovery.discoverAndLoadTools()

    XCTAssertEqual(count, 1)
    XCTAssertTrue(registry.hasToolNamed("test-tool"))

    // Cleanup
    try FileManager.default.removeItem(at: tempDir)
}
```

**2. Skip Non-Executable Files**:
```swift
func testSkipsNonExecutableFiles() async throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    // Create non-executable file
    let filePath = tempDir.appendingPathComponent("not-executable")
    try "test".write(to: filePath, atomically: true, encoding: .utf8)

    var config = Config.default
    config.externalTools.searchPaths = [tempDir.path]

    let registry = ToolRegistry()
    let discovery = ToolDiscovery(config: config, registry: registry)
    let count = await discovery.discoverAndLoadTools()

    XCTAssertEqual(count, 0)

    try FileManager.default.removeItem(at: tempDir)
}
```

**3. Handle Invalid Tools**:
```swift
func testHandlesInvalidToolsGracefully() async throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    // Create executable that returns invalid schema
    let toolPath = tempDir.appendingPathComponent("invalid-tool")
    try """
    #!/bin/bash
    echo "not json"
    """.write(to: URL(fileURLWithPath: toolPath.path), atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes(
        [.posixPermissions: 0o755],
        ofItemAtPath: toolPath.path
    )

    var config = Config.default
    config.externalTools.searchPaths = [tempDir.path]

    let registry = ToolRegistry()
    let discovery = ToolDiscovery(config: config, registry: registry)
    let count = await discovery.discoverAndLoadTools()

    // Should not crash, just skip invalid tool
    XCTAssertEqual(count, 0)

    try FileManager.default.removeItem(at: tempDir)
}
```

**4. Tool Registry**:
```swift
func testToolRegistry() {
    let registry = ToolRegistry()

    let tool1 = ReadFileTool()
    let tool2 = WriteFileTool()

    registry.register(tool1)
    registry.register(tool2)

    XCTAssertEqual(registry.allToolNames().count, 2)
    XCTAssertTrue(registry.hasToolNamed("read_file"))
    XCTAssertTrue(registry.hasToolNamed("write_file"))

    let retrieved = registry.tool(named: "read_file")
    XCTAssertNotNil(retrieved)
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Setup Test Tools Directory

```bash
cd systems/bootstrap/builds/test6
mkdir -p ~/.ybs/tools

# Create example tool
cat > ~/.ybs/tools/fortune << 'EOF'
#!/usr/bin/env python3
import json
import sys
import random

if "--schema" in sys.argv:
    print(json.dumps({
        "name": "fortune",
        "description": "Get a random fortune cookie message",
        "parameters": {}
    }))
else:
    fortunes = [
        "You will have a productive day.",
        "Good things come to those who code.",
        "A bug is just a feature in disguise."
    ]
    result = {
        "success": True,
        "result": random.choice(fortunes)
    }
    print(json.dumps(result))
EOF

chmod +x ~/.ybs/tools/fortune
```

### 2. Manual Testing

**Test tool discovery**:
```bash
swift run ybs --list-tools
# Should show:
# Available Tools:
#
#   edit_file (built-in)
#   fortune (external)
#     Get a random fortune cookie message
#     Path: /Users/scott/.ybs/tools/fortune
#   list_files (built-in)
#   read_file (built-in)
#   run_shell (built-in)
#   search_files (built-in)
#   write_file (built-in)
```

**Test tool usage**:
```bash
swift run ybs

You: Use the fortune tool
AI: <calls fortune tool>
Tool: You will have a productive day.
AI: The fortune says: "You will have a productive day."
```

### 3. Automated Testing

```bash
swift test --filter ToolDiscoveryTests
# All tests pass
```

### 4. Success Criteria

- ✅ Tools discovered from configured directories
- ✅ Executable files loaded, non-executable skipped
- ✅ Invalid tools skipped gracefully (no crash)
- ✅ Tools registered and available for execution
- ✅ --list-tools shows all available tools
- ✅ External tools callable from agent
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 4: Configuration loading
- Step 6: Error types
- Step 10: ToolExecutor
- Step 23: ExternalTool protocol

**Enables**:
- Complete extensible tool system
- Zero-config tool addition
- Community tools

---

## Implementation Notes

### Search Path Priority

**Order matters**:
1. Project-local tools (`./tools`, `./.ybs/tools`)
2. User tools (`~/.ybs/tools`)
3. System tools (`/usr/local/share/ybs/tools`)

**Later paths override earlier** if tool names conflict.

### Hidden Files

**Skip hidden files/directories**:
- Files starting with `.` ignored
- Prevents loading `.DS_Store`, etc.
- Prevents loading backup files (`.bak`)

### Error Handling

**Graceful degradation**:
- Invalid tool → Log warning, skip tool
- Schema load failure → Log warning, skip tool
- Directory not found → Log info, skip directory
- Never crash on tool loading errors

### Performance

**Optimize for startup time**:
- Parallel tool loading (async)
- Cache schemas (future enhancement)
- Lazy loading (future enhancement)

**Current approach**: Load all tools at startup (~100ms for 10 tools)

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Extensibility**:
- ✅ Zero-config tool addition
- ✅ Drop file in directory, it works
- ✅ No restart needed (future: watch directory)

**§ User Experience**:
- ✅ --list-tools shows what's available
- ✅ Clear tool names and descriptions
- ✅ Distinguish built-in vs external

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ToolDiscovery.swift with scanning logic
   - [ ] ToolRegistry.swift with thread-safe registry
   - [ ] Main.swift integration
   - [ ] CLI --list-tools flag

2. **Tests Pass**:
   - [ ] All ToolDiscoveryTests pass
   - [ ] Tool discovery works
   - [ ] Invalid tools handled
   - [ ] Registry operations work

3. **Verification Complete**:
   - [ ] Example external tools discovered
   - [ ] --list-tools shows all tools
   - [ ] External tools executable from agent

4. **Documentation Updated**:
   - [ ] Code comments explain discovery process
   - [ ] README shows how to add custom tools

**Estimated Time**: 2-3 hours
**Estimated Size**: ~200 lines

---

## Next Steps

**After This Step**:
→ **Step 25**: Token Counting & Tracking (context management)

**What It Enables**:
- Complete extensible tool system
- User-created tools just work
- Foundation for tool marketplace (future)

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
