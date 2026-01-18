# Step 000027: Repo Map Generation

**GUID**: a1b2c3d4e5f7
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Generate codebase map showing function/class signatures to provide LLM with structural context.

**What This Step Does**:
- Scans source files in working directory
- Extracts function/class/struct signatures
- Builds compact tree representation
- Includes in system prompt (~1-5K tokens)
- Caches to avoid regeneration

**Why This Step Exists**:
Without codebase context, LLM doesn't know:
- What files exist
- What functions are available
- How code is organized
- Where to make changes

Repo map provides structural awareness without reading every file.

**Dependencies**:
- ✅ Step 9: list_files tool (for file discovery)
- ✅ Step 8: read_file tool (for reading source)
- ✅ Step 25: Token counter (to limit size)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Context Management (Repo maps)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Signature-only repo maps

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 661-695 (Repo maps)
- `systems/bootstrap/docs/tool-architecture.md` (Context strategies)

---

## What to Build

### File Structure

```
Sources/YBS/Context/
├── RepoMap.swift              # Repo map generator
└── SignatureExtractor.swift   # Extract signatures from code
```

### 1. RepoMap.swift

**Purpose**: Generate codebase structure map.

**Key Components**:

```swift
public class RepoMap {
    private let workingDirectory: String
    private let tokenCounter: TokenCounter
    private let maxTokens: Int

    public init(
        workingDirectory: String,
        tokenCounter: TokenCounter,
        maxTokens: Int = 5000
    ) {
        self.workingDirectory = workingDirectory
        self.tokenCounter = tokenCounter
        self.maxTokens = maxTokens
    }

    /// Generate repo map
    /// - Returns: Formatted repo map string
    public func generate() async throws -> String

    /// Discover source files
    /// - Returns: List of source file paths
    private func discoverSourceFiles() throws -> [String]

    /// Extract signatures from file
    /// - Returns: List of signatures in file
    private func extractSignatures(from file: String) throws -> [Signature]

    /// Format repo map as tree
    /// - Returns: Formatted string representation
    private func formatAsTree(signatures: [String: [Signature]]) -> String

    /// Prune to fit within token limit
    /// - Returns: Pruned map
    private func pruneToFit(_ map: String) -> String
}

/// Signature representation
public struct Signature {
    public let type: SignatureType
    public let name: String
    public let file: String
    public let line: Int
    public let signature: String
}

public enum SignatureType {
    case function
    case method
    case `class`
    case `struct`
    case `enum`
    case `protocol`
}
```

**Implementation Details**:

1. **File Discovery**:
   ```swift
   func discoverSourceFiles() throws -> [String] {
       let fileManager = FileManager.default
       let enumerator = fileManager.enumerator(atPath: workingDirectory)

       var sourceFiles: [String] = []

       while let filename = enumerator?.nextObject() as? String {
           // Only source files
           guard isSourceFile(filename) else { continue }

           // Skip build directories
           if filename.contains("/build/") ||
              filename.contains("/.build/") ||
              filename.contains("/DerivedData/") {
               continue
           }

           let fullPath = (workingDirectory as NSString)
               .appendingPathComponent(filename)
           sourceFiles.append(fullPath)
       }

       return sourceFiles.sorted()
   }

   func isSourceFile(_ filename: String) -> Bool {
       let ext = (filename as NSString).pathExtension
       return ["swift", "m", "h", "c", "cpp", "py", "js", "ts"].contains(ext)
   }
   ```

2. **Signature Extraction**:
   ```swift
   func extractSignatures(from file: String) throws -> [Signature] {
       let content = try String(contentsOfFile: file, encoding: .utf8)
       let extractor = SignatureExtractor(language: detectLanguage(file))

       return try extractor.extract(from: content, file: file)
   }
   ```

3. **Tree Formatting**:
   ```swift
   func formatAsTree(signatures: [String: [Signature]]) -> String {
       var output = "# Codebase Structure\n\n"

       // Group by file
       for (file, sigs) in signatures.sorted(by: { $0.key < $1.key }) {
           let relativePath = file.replacingOccurrences(
               of: workingDirectory + "/",
               with: ""
           )
           output += "\n## \(relativePath)\n\n"

           for sig in sigs {
               let icon = iconForType(sig.type)
               output += "- \(icon) \(sig.signature)\n"
           }
       }

       return output
   }

   func iconForType(_ type: SignatureType) -> String {
       switch type {
       case .function, .method: return "func"
       case .class: return "class"
       case .struct: return "struct"
       case .enum: return "enum"
       case .protocol: return "protocol"
       }
   }
   ```

4. **Token Limiting**:
   ```swift
   func pruneToFit(_ map: String) -> String {
       var tokens = tokenCounter.count(map)

       guard tokens > maxTokens else {
           return map
       }

       // Strategy: Remove function signatures, keep types
       var lines = map.components(separatedBy: "\n")
       lines = lines.filter { !$0.contains("func") }

       let pruned = lines.joined(separator: "\n")
       tokens = tokenCounter.count(pruned)

       if tokens > maxTokens {
           // Further pruning: truncate
           return String(pruned.prefix(maxTokens * 4)) + "\n\n[Truncated]"
       }

       return pruned
   }
   ```

5. **Generation**:
   ```swift
   func generate() async throws -> String {
       Logger.info("Generating repo map...")

       // Discover files
       let files = try discoverSourceFiles()
       Logger.debug("Found \(files.count) source files")

       // Extract signatures
       var allSignatures: [String: [Signature]] = [:]

       for file in files {
           do {
               let sigs = try extractSignatures(from: file)
               if !sigs.isEmpty {
                   allSignatures[file] = sigs
               }
           } catch {
               Logger.warning("Failed to extract from \(file): \(error)")
           }
       }

       // Format
       var map = formatAsTree(signatures: allSignatures)

       // Prune to fit token limit
       map = pruneToFit(map)

       Logger.info("Repo map generated (\(tokenCounter.count(map)) tokens)")

       return map
   }
   ```

**Size**: ~200 lines

---

### 2. SignatureExtractor.swift

**Purpose**: Extract function/class signatures from source code.

**Key Components**:

```swift
public class SignatureExtractor {
    private let language: Language

    public init(language: Language) {
        self.language = language
    }

    /// Extract signatures from source code
    public func extract(
        from content: String,
        file: String
    ) throws -> [Signature]

    /// Extract Swift signatures
    private func extractSwift(_ content: String, file: String) -> [Signature]

    /// Extract Python signatures
    private func extractPython(_ content: String, file: String) -> [Signature]

    /// Extract JavaScript/TypeScript signatures
    private func extractJavaScript(_ content: String, file: String) -> [Signature]
}

public enum Language {
    case swift
    case python
    case javascript
    case typescript
    case c
    case cpp
    case unknown
}
```

**Implementation Details**:

1. **Swift Extraction** (regex-based):
   ```swift
   func extractSwift(_ content: String, file: String) -> [Signature] {
       var signatures: [Signature] = []
       let lines = content.components(separatedBy: "\n")

       for (lineNum, line) in lines.enumerated() {
           let trimmed = line.trimmingCharacters(in: .whitespaces)

           // Class/struct/enum/protocol
           if let match = trimmed.range(
               of: #"^(public |private |internal )?(class|struct|enum|protocol) (\w+)"#,
               options: .regularExpression
           ) {
               let name = extractName(from: trimmed, pattern: #"(class|struct|enum|protocol) (\w+)"#)
               signatures.append(Signature(
                   type: typeFromKeyword(trimmed),
                   name: name,
                   file: file,
                   line: lineNum + 1,
                   signature: trimmed.components(separatedBy: "{").first ?? trimmed
               ))
           }

           // Function/method
           if let match = trimmed.range(
               of: #"^(public |private |internal )?func \w+"#,
               options: .regularExpression
           ) {
               let name = extractName(from: trimmed, pattern: #"func (\w+)"#)
               signatures.append(Signature(
                   type: .function,
                   name: name,
                   file: file,
                   line: lineNum + 1,
                   signature: extractFunctionSignature(trimmed)
               ))
           }
       }

       return signatures
   }

   func extractFunctionSignature(_ line: String) -> String {
       // Extract up to opening brace
       if let braceIndex = line.firstIndex(of: "{") {
           return String(line[..<braceIndex]).trimmingCharacters(in: .whitespaces)
       }
       return line
   }
   ```

2. **Python Extraction**:
   ```swift
   func extractPython(_ content: String, file: String) -> [Signature] {
       var signatures: [Signature] = []
       let lines = content.components(separatedBy: "\n")

       for (lineNum, line) in lines.enumerated() {
           let trimmed = line.trimmingCharacters(in: .whitespaces)

           // Class
           if trimmed.hasPrefix("class ") {
               let name = extractName(from: trimmed, pattern: #"class (\w+)"#)
               signatures.append(Signature(
                   type: .class,
                   name: name,
                   file: file,
                   line: lineNum + 1,
                   signature: trimmed.components(separatedBy: ":").first ?? trimmed
               ))
           }

           // Function/method
           if trimmed.hasPrefix("def ") {
               let name = extractName(from: trimmed, pattern: #"def (\w+)"#)
               signatures.append(Signature(
                   type: .function,
                   name: name,
                   file: file,
                   line: lineNum + 1,
                   signature: trimmed.components(separatedBy: ":").first ?? trimmed
               ))
           }
       }

       return signatures
   }
   ```

3. **Helper Methods**:
   ```swift
   func extractName(from line: String, pattern: String) -> String {
       guard let regex = try? NSRegularExpression(pattern: pattern),
             let match = regex.firstMatch(
                 in: line,
                 range: NSRange(line.startIndex..., in: line)
             ),
             match.numberOfRanges >= 2 else {
           return ""
       }

       let range = match.range(at: match.numberOfRanges - 1)
       return String(line[Range(range, in: line)!])
   }

   func typeFromKeyword(_ line: String) -> SignatureType {
       if line.contains("class ") { return .class }
       if line.contains("struct ") { return .struct }
       if line.contains("enum ") { return .enum }
       if line.contains("protocol ") { return .protocol }
       return .function
   }
   ```

**Size**: ~250 lines

---

### 3. Integration with Agent

**Update**: Agent to include repo map in system prompt

```swift
class Agent {
    func run() async throws {
        // Generate repo map once at start
        let repoMap = RepoMap(
            workingDirectory: config.workingDirectory,
            tokenCounter: TokenCounter(),
            maxTokens: 5000
        )

        let map = try await repoMap.generate()

        // Add to system prompt
        let systemPrompt = """
        You are an AI coding assistant.

        \(map)

        Use the above codebase structure to understand the project.
        When making changes, reference specific files and functions.
        """

        context.addSystemMessage(systemPrompt)

        // Start conversation loop
        // ...
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "context": {
    "repoMap": {
      "enabled": true,
      "maxTokens": 5000,
      "includeTests": false,
      "includeDependencies": false
    }
  }
}
```

**Configuration Options**:
- `enabled`: Generate repo map (true/false)
- `maxTokens`: Max tokens for map (1000-10000)
- `includeTests`: Include test files
- `includeDependencies`: Include dependencies

---

## Tests

**Location**: `Tests/YBSTests/Context/RepoMapTests.swift`

### Test Cases

**1. File Discovery**:
```swift
func testDiscoverSourceFiles() throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    // Create test files
    try "".write(to: tempDir.appendingPathComponent("test.swift"), atomically: true, encoding: .utf8)
    try "".write(to: tempDir.appendingPathComponent("main.py"), atomically: true, encoding: .utf8)
    try "".write(to: tempDir.appendingPathComponent("README.md"), atomically: true, encoding: .utf8)

    let repoMap = RepoMap(
        workingDirectory: tempDir.path,
        tokenCounter: TokenCounter()
    )

    let files = try repoMap.discoverSourceFiles()

    // Should find .swift and .py, not .md
    XCTAssertEqual(files.count, 2)

    try FileManager.default.removeItem(at: tempDir)
}
```

**2. Signature Extraction**:
```swift
func testExtractSwiftSignatures() throws {
    let code = """
    class MyClass {
        func myMethod() -> String {
            return "test"
        }
    }

    func topLevelFunction(param: Int) -> Bool {
        return true
    }
    """

    let extractor = SignatureExtractor(language: .swift)
    let signatures = try extractor.extract(from: code, file: "test.swift")

    XCTAssertEqual(signatures.count, 3) // class + 2 functions
    XCTAssertTrue(signatures.contains { $0.name == "MyClass" })
    XCTAssertTrue(signatures.contains { $0.name == "myMethod" })
    XCTAssertTrue(signatures.contains { $0.name == "topLevelFunction" })
}
```

**3. Token Limiting**:
```swift
func testPrunesLargeMap() {
    let repoMap = RepoMap(
        workingDirectory: "/tmp",
        tokenCounter: TokenCounter(),
        maxTokens: 100
    )

    // Generate large map
    var largeMap = ""
    for i in 0..<1000 {
        largeMap += "func function\(i)() -> Void\n"
    }

    let pruned = repoMap.pruneToFit(largeMap)
    let tokens = TokenCounter().count(pruned)

    XCTAssertLessThanOrEqual(tokens, 100)
}
```

**Total Tests**: ~6-8 tests

---

## Verification Steps

### 1. Manual Testing

**Test repo map generation**:
```bash
cd systems/bootstrap/builds/test6
swift run ybs --show-repo-map

# Should output:
# Codebase Structure
#
# ## Sources/YBS/main.swift
# - func main() async throws
#
# ## Sources/YBS/Agent/Agent.swift
# - class Agent
# - func run() async throws
# - func processMessage(_ message: String) async throws
#
# [... etc ...]
```

**Test in conversation**:
```bash
swift run ybs

You: What files are in this project?
AI: Based on the codebase structure, this project has:
- Sources/YBS/main.swift (entry point)
- Sources/YBS/Agent/Agent.swift (agent implementation)
- Sources/YBS/Tools/ (various tool implementations)
[... uses repo map ...]
```

### 2. Automated Testing

```bash
swift test --filter RepoMapTests
# All tests pass
```

### 3. Success Criteria

- ✅ Source files discovered correctly
- ✅ Signatures extracted (Swift, Python, JS)
- ✅ Map formatted as tree
- ✅ Token limit enforced (<5K tokens)
- ✅ Build directories skipped
- ✅ Map included in system prompt
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 8: read_file (for reading source)
- Step 9: list_files (for file discovery)
- Step 25: Token counter

**Enables**:
- Better LLM code awareness
- More accurate file/function references
- Reduced "where is X?" questions

---

## Implementation Notes

### Extraction Strategies

**Regex vs Tree-sitter**:
- Regex: Simple, fast, good enough
- Tree-sitter: Accurate, complex, heavy dependency
- For YBS: Regex sufficient (just need signatures)

**Why Regex Works**:
- Only need top-level signatures
- Don't need perfect parsing
- ~95% accuracy acceptable
- No dependencies required

### Performance

**Generation cost**:
- Scan 100 files: ~100ms
- Extract signatures: ~500ms
- Format: ~50ms
- Total: ~650ms (acceptable startup cost)

**Optimization**:
- Cache generated map (Step 30)
- Only regenerate if files changed
- Parallel file processing

### Token Budget

**Typical token usage**:
- Small project (10 files): ~500 tokens
- Medium project (50 files): ~2,000 tokens
- Large project (200 files): ~5,000 tokens (pruned)

**Pruning strategy**:
1. Remove function signatures, keep types
2. Remove test files
3. Truncate if still too large

---

## Future Enhancements

**Possible improvements**:
- Tree-sitter parsing (more accurate)
- Semantic ranking (show important code)
- Incremental updates (watch filesystem)
- User-defined excludes (ignore certain dirs)

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Context Efficiency**:
- ✅ Signatures only (not full code)
- ✅ Token limit enforced
- ✅ Pruning strategy

**§ Language Support**:
- ✅ Start with Swift (our language)
- ✅ Easy to add more languages
- ✅ Graceful degradation (unknown language = skip)

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] RepoMap.swift with generation logic
   - [ ] SignatureExtractor.swift with extraction
   - [ ] Agent integration (system prompt)
   - [ ] CLI flag --show-repo-map

2. **Tests Pass**:
   - [ ] All RepoMapTests pass
   - [ ] Signatures extracted correctly
   - [ ] Token limit enforced
   - [ ] Build dirs skipped

3. **Verification Complete**:
   - [ ] Repo map visible with --show-repo-map
   - [ ] LLM uses map in responses
   - [ ] Performance acceptable (<1s)

4. **Documentation Updated**:
   - [ ] Code comments explain extraction
   - [ ] Config options documented

**Estimated Time**: 4-5 hours
**Estimated Size**: ~450 lines

---

## Next Steps

**After This Step**:
→ **Step 28**: Colored Output & UX (polish layer begins)

**What It Enables**:
- LLM awareness of codebase structure
- Better file/function references
- Reduced context reads

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
