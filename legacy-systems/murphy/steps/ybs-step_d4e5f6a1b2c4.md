# Step 000030: Performance Optimization

**GUID**: d4e5f6a1b2c4
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Optimize system performance for speed and efficiency.

**What This Step Does**:
- Parallel tool execution (when LLM requests multiple tools)
- Cache repo maps (avoid regenerating)
- Lazy loading (defer expensive operations)
- Connection pooling for HTTP
- Startup time optimization

**Why This Step Exists**:
After Steps 4-29, system is fully functional but not optimized:
- Sequential tool execution is slow
- Repo map regenerated on every run
- All tools loaded at startup
- Each HTTP request creates new connection

This step makes the system fast and efficient.

**Dependencies**:
- All previous steps (this is optimization pass over everything)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Performance
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Performance optimizations

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 781-810 (Performance)

---

## What to Build

### File Structure

```
Sources/YBS/Performance/
├── ParallelExecutor.swift     # Parallel tool execution
├── CacheManager.swift         # Caching layer
└── LazyLoader.swift           # Lazy loading utilities
```

### 1. ParallelExecutor.swift

**Purpose**: Execute multiple tools in parallel.

**Key Components**:

```swift
public class ParallelExecutor {
    private let executor: ToolExecutor

    public init(executor: ToolExecutor) {
        self.executor = executor
    }

    /// Execute multiple tool calls in parallel
    /// - Returns: Array of tool results (same order as input)
    public func executeParallel(
        _ toolCalls: [ToolCall]
    ) async throws -> [ToolResult] {
        // Use task group for structured concurrency
        return try await withThrowingTaskGroup(of: (Int, ToolResult).self) { group in
            // Start all tasks
            for (index, toolCall) in toolCalls.enumerated() {
                group.addTask {
                    let result = try await self.executor.execute(toolCall)
                    return (index, result)
                }
            }

            // Collect results
            var results: [(Int, ToolResult)] = []
            for try await result in group {
                results.append(result)
            }

            // Sort by original order
            results.sort { $0.0 < $1.0 }

            return results.map { $0.1 }
        }
    }

    /// Check if tools can be parallelized
    /// - Returns: true if safe to run in parallel
    public func canParallelize(_ toolCalls: [ToolCall]) -> Bool {
        // Check for dependencies

        // 1. No write operations (unsafe to parallel)
        let hasWrite = toolCalls.contains { call in
            ["write_file", "edit_file", "run_shell"].contains(call.name)
        }

        if hasWrite {
            return false
        }

        // 2. No duplicate paths (race condition)
        var paths: Set<String> = []
        for call in toolCalls {
            if let path = call.parameters["path"] as? String {
                if paths.contains(path) {
                    return false
                }
                paths.insert(path)
            }
        }

        // Safe to parallelize
        return true
    }
}
```

**Size**: ~100 lines

---

### 2. CacheManager.swift

**Purpose**: Cache expensive operations.

**Key Components**:

```swift
public class CacheManager {
    private var cache: [String: CacheEntry] = [:]
    private let lock = NSLock()

    /// Cache entry with expiration
    private struct CacheEntry {
        let value: Any
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    /// Get from cache
    public func get<T>(_ key: String) -> T? {
        lock.withLock {
            guard let entry = cache[key],
                  !entry.isExpired else {
                return nil
            }

            return entry.value as? T
        }
    }

    /// Set in cache
    public func set<T>(
        _ key: String,
        value: T,
        ttl: TimeInterval = 3600
    ) {
        lock.withLock {
            cache[key] = CacheEntry(
                value: value,
                timestamp: Date(),
                ttl: ttl
            )
        }
    }

    /// Invalidate cache entry
    public func invalidate(_ key: String) {
        lock.withLock {
            cache.removeValue(forKey: key)
        }
    }

    /// Clear all cache
    public func clearAll() {
        lock.withLock {
            cache.removeAll()
        }
    }

    /// Prune expired entries
    public func pruneExpired() {
        lock.withLock {
            cache = cache.filter { !$0.value.isExpired }
        }
    }
}

/// Global cache instance
public let globalCache = CacheManager()
```

**Size**: ~100 lines

---

### 3. LazyLoader.swift

**Purpose**: Lazy loading utilities.

**Key Components**:

```swift
/// Lazy value that loads on first access
public class Lazy<T> {
    private var value: T?
    private let loader: () throws -> T
    private let lock = NSLock()

    public init(loader: @escaping () throws -> T) {
        self.loader = loader
    }

    /// Get value (loads if needed)
    public func get() throws -> T {
        lock.withLock {
            if let value = value {
                return value
            }

            let loaded = try loader()
            value = loaded
            return loaded
        }
    }

    /// Check if loaded
    public var isLoaded: Bool {
        lock.withLock {
            value != nil
        }
    }

    /// Reset (force reload on next access)
    public func reset() {
        lock.withLock {
            value = nil
        }
    }
}

/// Async lazy value
public actor AsyncLazy<T> {
    private var value: T?
    private let loader: () async throws -> T

    public init(loader: @escaping () async throws -> T) {
        self.loader = loader
    }

    public func get() async throws -> T {
        if let value = value {
            return value
        }

        let loaded = try await loader()
        value = loaded
        return loaded
    }

    public var isLoaded: Bool {
        value != nil
    }

    public func reset() {
        value = nil
    }
}
```

**Size**: ~80 lines

---

### 4. Optimization: Parallel Tool Execution

**Update**: `Sources/YBS/Agent/AgentLoop.swift`

```swift
func handleToolCalls(_ toolCalls: [ToolCall]) async throws {
    let parallelExecutor = ParallelExecutor(executor: toolExecutor)

    // Check if can parallelize
    if toolCalls.count > 1 && parallelExecutor.canParallelize(toolCalls) {
        Logger.info("Executing \(toolCalls.count) tools in parallel")

        let results = try await parallelExecutor.executeParallel(toolCalls)

        for (call, result) in zip(toolCalls, results) {
            colorOutput.printToolCall(call.name)
            colorOutput.printToolResult(result.content, success: result.isSuccess)

            context.addMessage(Message(
                role: .tool,
                content: .toolResult(result)
            ))
        }

    } else {
        // Sequential execution (original logic)
        for call in toolCalls {
            colorOutput.printToolCall(call.name)

            let result = try await toolExecutor.execute(call)

            colorOutput.printToolResult(result.content, success: result.isSuccess)

            context.addMessage(Message(
                role: .tool,
                content: .toolResult(result)
            ))
        }
    }
}
```

---

### 5. Optimization: Cached Repo Map

**Update**: `Sources/YBS/Context/RepoMap.swift`

```swift
public class RepoMap {
    private static let cacheKey = "repo_map"
    private static let cacheTTL: TimeInterval = 3600 // 1 hour

    public func generate() async throws -> String {
        // Check cache
        if let cached: String = globalCache.get(Self.cacheKey) {
            Logger.debug("Using cached repo map")
            return cached
        }

        Logger.info("Generating repo map...")

        // Generate (expensive)
        let map = try await generateFresh()

        // Cache for 1 hour
        globalCache.set(Self.cacheKey, value: map, ttl: Self.cacheTTL)

        return map
    }

    /// Invalidate cache (call when files change)
    public static func invalidateCache() {
        globalCache.invalidate(cacheKey)
    }

    private func generateFresh() async throws -> String {
        // Original generation logic
        // ...
    }
}
```

---

### 6. Optimization: Lazy Tool Loading

**Update**: `Sources/YBS/Tools/ToolRegistry.swift`

```swift
public class ToolRegistry {
    private var tools: [String: Lazy<Tool>] = [:]

    /// Register tool with lazy loading
    public func registerLazy(
        _ name: String,
        loader: @escaping () throws -> Tool
    ) {
        tools[name] = Lazy(loader: loader)
    }

    /// Get tool (loads if needed)
    public func tool(named name: String) throws -> Tool? {
        try tools[name]?.get()
    }

    /// Pre-load all tools
    public func preloadAll() throws {
        for (_, lazyTool) in tools {
            _ = try lazyTool.get()
        }
    }
}
```

---

### 7. Optimization: HTTP Connection Pooling

**Update**: `Sources/YBS/HTTP/HTTPClient.swift`

```swift
public class HTTPClient {
    // URLSession with connection pooling
    private let session: URLSession

    public init(config: HTTPConfig) {
        let configuration = URLSessionConfiguration.default

        // Connection pooling
        configuration.httpMaximumConnectionsPerHost = 6
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 300.0

        // HTTP/2 multiplexing
        configuration.httpShouldUsePipelining = true

        // Keep-alive
        configuration.httpAdditionalHeaders = [
            "Connection": "keep-alive"
        ]

        self.session = URLSession(configuration: configuration)
    }

    // Reuse session for all requests
}
```

---

### 8. Optimization: Startup Time

**Update**: `Sources/YBS/main.swift`

```swift
@main
struct YBS {
    static func main() async throws {
        let startTime = Date()

        // 1. Load config (fast)
        let config = try ConfigLoader.load()

        // 2. Create registry with lazy loading
        let registry = ToolRegistry()

        // Register built-in tools (lazy)
        registry.registerLazy("read_file") {
            ReadFileTool()
        }
        registry.registerLazy("write_file") {
            WriteFileTool()
        }
        // ... etc

        // 3. Discover external tools (async, don't block)
        Task {
            let discovery = ToolDiscovery(config: config, registry: registry)
            await discovery.discoverAndLoadTools()
        }

        // 4. Start agent immediately
        let agent = Agent(config: config, registry: registry)

        let elapsed = Date().timeIntervalSince(startTime)
        Logger.debug("Startup time: \(String(format: "%.2f", elapsed))s")

        try await agent.run()
    }
}
```

---

## Benchmarks

**Create**: `Tests/YBSTests/Performance/BenchmarkTests.swift`

```swift
import XCTest

final class BenchmarkTests: XCTestCase {
    func testParallelToolExecution() async throws {
        let calls = [
            ToolCall(name: "read_file", parameters: ["path": "file1.txt"]),
            ToolCall(name: "read_file", parameters: ["path": "file2.txt"]),
            ToolCall(name: "read_file", parameters: ["path": "file3.txt"])
        ]

        // Sequential
        let sequentialStart = Date()
        for call in calls {
            _ = try await executor.execute(call)
        }
        let sequentialTime = Date().timeIntervalSince(sequentialStart)

        // Parallel
        let parallelStart = Date()
        _ = try await parallelExecutor.executeParallel(calls)
        let parallelTime = Date().timeIntervalSince(parallelStart)

        // Parallel should be faster
        XCTAssertLessThan(parallelTime, sequentialTime * 0.6)

        print("Sequential: \(sequentialTime)s")
        print("Parallel: \(parallelTime)s")
        print("Speedup: \(sequentialTime / parallelTime)x")
    }

    func testRepoMapCaching() async throws {
        let repoMap = RepoMap(...)

        // First generation (cache miss)
        let firstStart = Date()
        _ = try await repoMap.generate()
        let firstTime = Date().timeIntervalSince(firstStart)

        // Second generation (cache hit)
        let secondStart = Date()
        _ = try await repoMap.generate()
        let secondTime = Date().timeIntervalSince(secondStart)

        // Cached should be much faster
        XCTAssertLessThan(secondTime, firstTime * 0.1)

        print("First: \(firstTime)s")
        print("Cached: \(secondTime)s")
    }

    func testStartupTime() throws {
        // Measure startup
        measure {
            // Initialize everything
            let config = try! ConfigLoader.load()
            let registry = ToolRegistry()
            // ... etc
        }

        // Should be < 100ms
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "performance": {
    "parallelTools": true,
    "cacheEnabled": true,
    "cacheTTL": 3600,
    "lazyLoading": true,
    "httpConnectionPool": 6
  }
}
```

---

## Tests

**Location**: `Tests/YBSTests/Performance/`

### Test Cases

**1. Parallel Execution**:
```swift
func testParallelExecution() async throws {
    let executor = ParallelExecutor(executor: toolExecutor)

    let calls = [
        ToolCall(name: "read_file", parameters: ["path": "a.txt"]),
        ToolCall(name: "read_file", parameters: ["path": "b.txt"])
    ]

    let results = try await executor.executeParallel(calls)

    XCTAssertEqual(results.count, 2)
    XCTAssertTrue(results[0].isSuccess)
    XCTAssertTrue(results[1].isSuccess)
}
```

**2. Cache Hit/Miss**:
```swift
func testCache() {
    let cache = CacheManager()

    // Miss
    let miss: String? = cache.get("key")
    XCTAssertNil(miss)

    // Set
    cache.set("key", value: "value")

    // Hit
    let hit: String? = cache.get("key")
    XCTAssertEqual(hit, "value")
}
```

**3. Lazy Loading**:
```swift
func testLazyLoading() throws {
    var loadCount = 0

    let lazy = Lazy {
        loadCount += 1
        return "value"
    }

    XCTAssertFalse(lazy.isLoaded)
    XCTAssertEqual(loadCount, 0)

    let value1 = try lazy.get()
    XCTAssertEqual(loadCount, 1)
    XCTAssertEqual(value1, "value")

    let value2 = try lazy.get()
    XCTAssertEqual(loadCount, 1) // Not loaded again
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Manual Testing

**Test parallel tools**:
```bash
swift run ybs

You: Read files a.txt, b.txt, and c.txt
[INFO] Executing 3 tools in parallel
→ read_file (path: a.txt)
→ read_file (path: b.txt)
→ read_file (path: c.txt)
✓ Success (all 3 complete quickly)
AI: Here are the contents...
```

**Test repo map caching**:
```bash
# First run
swift run ybs
[INFO] Generating repo map... (650ms)

# Second run (same session)
swift run ybs
[DEBUG] Using cached repo map (1ms)
```

### 2. Benchmark Testing

```bash
swift test --filter BenchmarkTests

# Should show:
# Sequential tool execution: 1.5s
# Parallel tool execution: 0.5s
# Speedup: 3x
#
# Repo map generation: 650ms
# Repo map cached: 5ms
```

### 3. Startup Time

```bash
time swift run ybs --version

# Should be < 100ms
```

### 4. Success Criteria

- ✅ Parallel tool execution works (2-3x faster)
- ✅ Repo map cached (10-100x faster on reuse)
- ✅ Lazy loading reduces startup time
- ✅ HTTP connection pooling enabled
- ✅ Startup time < 100ms
- ✅ All benchmarks pass
- ✅ All tests pass

---

## Dependencies

**Requires**:
- All previous steps (optimization layer)

**Enables**:
- Fast, responsive system
- Efficient resource usage
- Production-ready performance

---

## Implementation Notes

### When to Parallelize

**Safe**:
- Multiple read_file calls
- Multiple list_files calls
- Multiple search_files calls

**Unsafe**:
- Write operations (race conditions)
- Same file accessed multiple times
- Dependent operations

### Cache Invalidation

**When to invalidate**:
- File system changes detected
- User runs --clear-cache flag
- Cache TTL expired (default 1 hour)

**Cache keys**:
- repo_map
- tool_schemas
- config

### Lazy Loading Benefits

**Reduces startup time**:
- Before: Load all 20 tools = 200ms
- After: Load 0 tools at startup = 0ms
- Tools loaded on first use

### HTTP Connection Pooling

**Benefits**:
- Reuse TCP connections
- Reduce handshake overhead
- Support HTTP/2 multiplexing

---

## Performance Targets

**Goals**:
- Startup: < 100ms
- Read file: < 50ms
- LLM request: < 3s (network dependent)
- Repo map (cached): < 10ms
- Parallel tools: 2-3x faster than sequential

---

## Future Enhancements

**Possible improvements**:
- Incremental repo map updates
- Background cache warming
- Predictive tool loading
- Request batching
- Memory usage profiling

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Performance**:
- ✅ Measure before optimizing (benchmarks)
- ✅ Parallelize where safe
- ✅ Cache expensive operations
- ✅ Lazy load when possible

**§ Resource Efficiency**:
- ✅ Connection pooling
- ✅ Minimal memory usage
- ✅ Fast startup time

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ParallelExecutor.swift with parallel execution
   - [ ] CacheManager.swift with caching
   - [ ] LazyLoader.swift with lazy loading
   - [ ] All optimizations integrated

2. **Benchmarks Pass**:
   - [ ] Parallel execution 2-3x faster
   - [ ] Cached repo map 10x+ faster
   - [ ] Startup time < 100ms

3. **Tests Pass**:
   - [ ] All PerformanceTests pass
   - [ ] Parallel execution correct
   - [ ] Cache works correctly

4. **Documentation Updated**:
   - [ ] Code comments explain optimizations
   - [ ] Performance targets documented

**Estimated Time**: 3-4 hours
**Estimated Size**: ~280 lines

---

## 🎉 FINAL STEP COMPLETE!

**After This Step**:
→ **System Complete!** All 30 steps documented (0-30)

**What It Enables**:
- Fast, responsive system
- Production-ready performance
- Professional quality

---

## System Complete

**Total Steps**: 31 (0-30)
**Total Lines**: ~4,000-5,000 (estimated)
**Total Features**:
- ✅ Configuration system
- ✅ Core data models
- ✅ Error handling
- ✅ CLI interface
- ✅ File tools (read, write, edit, search)
- ✅ LLM client
- ✅ Agent loop
- ✅ Tool calling
- ✅ Context management
- ✅ Safety & sandboxing
- ✅ External tools
- ✅ Token tracking
- ✅ Context compaction
- ✅ Repo maps
- ✅ Colored output
- ✅ Error recovery
- ✅ Performance optimization

**Ready to build!** 🚀

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
