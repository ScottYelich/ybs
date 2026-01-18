# Step 000041: Session Persistence and Management

**GUID**: d1e2f3a4b5c6
**Version**: 0.1.0
**Estimated Duration**: 25 minutes

## Objectives
- Implement file-based session persistence using JSONL format
- Add session configuration to config system
- Create SessionManager class for managing session files
- Add meta-commands for session management (/sessions, /load, /save, /session)
- Enable automatic session saving and loading
- Implement session cleanup and retention policies

## Prerequisites
- Step 36 completed (Shell Injection, meta-commands infrastructure exists)
- Configuration system in place (Config.swift, ConfigLoader.swift)
- MetaCommandHandler exists and can be extended
- AgentLoop can be modified to use SessionManager

## Instructions

### 1. Update Configuration Schema

#### 1.1 Add SessionConfig to Config.swift

Add new configuration structure:

```swift
// Session configuration
struct SessionConfig: Codable {
    var storagePath: String = "~/.config/ybs/sessions"
    var autoSave: Bool = true
    var maxSessions: Int = 100
    var retentionDays: Int = 30

    enum CodingKeys: String, CodingKey {
        case storagePath = "storage_path"
        case autoSave = "auto_save"
        case maxSessions = "max_sessions"
        case retentionDays = "retention_days"
    }
}
```

#### 1.2 Add SessionConfig to YBSConfig

Modify `YBSConfig` struct to include session configuration:

```swift
struct YBSConfig: Codable {
    var version: String
    var llm: LLMConfig
    var context: ContextConfig
    var agent: AgentConfig
    var safety: SafetyConfig
    var tools: ToolsConfig
    var git: GitConfig
    var ui: UIConfig
    var session: SessionConfig  // NEW

    init() {
        // ... existing inits ...
        self.session = SessionConfig()
    }

    init(from decoder: Decoder) throws {
        // ... existing decoding ...
        self.session = try container.decodeIfPresent(SessionConfig.self, forKey: .session) ?? SessionConfig()
    }
}
```

### 2. Create Session Models

Create `Sources/YBS/Models/SessionEvent.swift`:

```swift
import Foundation

/// Event types that can be recorded in a session
enum SessionEventType: String, Codable {
    case sessionStart = "session_start"
    case sessionEnd = "session_end"
    case system
    case user
    case assistant
    case toolCall = "tool_call"
    case toolResult = "tool_result"
}

/// A single event in a session log
struct SessionEvent: Codable {
    let timestamp: Date
    let type: SessionEventType

    // Content fields (optional based on type)
    var content: String?
    var toolCallId: String?
    var toolName: String?
    var toolArguments: String?
    var toolSuccess: Bool?
    var toolOutput: String?

    // Metadata fields
    var config: SessionMetadata?
    var reason: String?
    var messageCount: Int?

    enum CodingKeys: String, CodingKey {
        case timestamp, type, content
        case toolCallId = "tool_call_id"
        case toolName = "tool_name"
        case toolArguments = "tool_arguments"
        case toolSuccess = "tool_success"
        case toolOutput = "tool_output"
        case config, reason
        case messageCount = "message_count"
    }
}

/// Session metadata stored at session start
struct SessionMetadata: Codable {
    let provider: String
    let model: String
    let endpoint: String?

    init(from llmConfig: LLMConfig) {
        self.provider = llmConfig.provider
        self.model = llmConfig.model
        self.endpoint = llmConfig.endpoint
    }
}

/// Information about a saved session
struct SessionInfo {
    let filename: String
    let timestamp: Date
    let messageCount: Int
    let config: SessionMetadata

    var displayName: String {
        // Remove .jsonl extension
        String(filename.dropLast(6))
    }

    var age: String {
        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}
```

### 3. Create SessionManager Class

Create `Sources/YBS/Agent/SessionManager.swift`:

```swift
import Foundation

/// Manages session persistence using JSONL files
class SessionManager {
    private let config: SessionConfig
    private let logger: Logger
    private let storageURL: URL
    private(set) var currentSessionFile: URL?

    init(config: SessionConfig, logger: Logger) {
        self.config = config
        self.logger = logger

        // Expand ~ in storage path
        let expandedPath = NSString(string: config.storagePath).expandingTildeInPath
        self.storageURL = URL(fileURLWithPath: expandedPath)

        // Ensure storage directory exists
        try? FileManager.default.createDirectory(
            at: storageURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]  // User-only access
        )
    }

    /// Start a new session and return the session file URL
    func startNewSession(llmConfig: LLMConfig) -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .prefix(15)  // YYYYMMDDTHHMMSS

        let filename = "session-\(timestamp).jsonl"
        let fileURL = storageURL.appendingPathComponent(filename)

        currentSessionFile = fileURL

        // Write session start event
        let event = SessionEvent(
            timestamp: Date(),
            type: .sessionStart,
            config: SessionMetadata(from: llmConfig)
        )
        appendEvent(event)

        logger.info("Started new session: \(filename)")
        return fileURL
    }

    /// Append an event to the current session
    func appendEvent(_ event: SessionEvent) {
        guard config.autoSave else { return }
        guard let fileURL = currentSessionFile else { return }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(event)
            let line = String(data: data, encoding: .utf8)! + "\n"

            if FileManager.default.fileExists(atPath: fileURL.path) {
                // Append to existing file
                let handle = try FileHandle(forWritingTo: fileURL)
                handle.seekToEndOfFile()
                handle.write(line.data(using: .utf8)!)
                try handle.close()
            } else {
                // Create new file
                try line.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            logger.error("Failed to append session event: \(error)")
        }
    }

    /// Save current session with a custom name
    func saveSessionAs(_ name: String) throws {
        guard let currentFile = currentSessionFile else {
            throw YBSError.sessionError(message: "No active session to save")
        }

        let newFilename = "\(name).jsonl"
        let newURL = storageURL.appendingPathComponent(newFilename)

        try FileManager.default.copyItem(at: currentFile, to: newURL)
        logger.info("Saved session as: \(newFilename)")
    }

    /// Load a session and return conversation context
    func loadSession(_ filename: String) throws -> ConversationContext {
        var fullFilename = filename
        if !filename.hasSuffix(".jsonl") {
            fullFilename += ".jsonl"
        }

        let fileURL = storageURL.appendingPathComponent(fullFilename)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw YBSError.sessionError(message: "Session not found: \(filename)")
        }

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.split(separator: "\n")

        var context = ConversationContext(maxMessages: 1000, logger: logger)
        var messageCount = 0

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for line in lines {
            guard !line.isEmpty else { continue }

            let event = try decoder.decode(SessionEvent.self, from: Data(line.utf8))

            switch event.type {
            case .system:
                if let content = event.content {
                    context.addMessage(Message(role: .system, content: content))
                    messageCount += 1
                }

            case .user:
                if let content = event.content {
                    context.addMessage(Message(role: .user, content: content))
                    messageCount += 1
                }

            case .assistant:
                if let content = event.content {
                    context.addMessage(Message(role: .assistant, content: content))
                    messageCount += 1
                }

            case .toolCall:
                // Reconstruct tool call message
                if let toolName = event.toolName,
                   let toolArgs = event.toolArguments,
                   let toolCallId = event.toolCallId {
                    let toolCall = ToolCall(
                        id: toolCallId,
                        function: ToolFunction(name: toolName, arguments: toolArgs)
                    )
                    context.addMessage(Message(role: .assistant, toolCalls: [toolCall]))
                    messageCount += 1
                }

            case .toolResult:
                // Add tool result from log (don't re-execute)
                if let toolCallId = event.toolCallId,
                   let toolName = event.toolName,
                   let output = event.toolOutput {
                    context.addMessage(Message(
                        role: .tool,
                        content: output,
                        name: toolName,
                        toolCallId: toolCallId
                    ))
                    messageCount += 1
                }

            case .sessionStart, .sessionEnd:
                // Metadata events, don't add to context
                break
            }
        }

        logger.info("Loaded session: \(filename) (\(messageCount) messages)")
        return context
    }

    /// List all available sessions
    func listSessions() -> [SessionInfo] {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: storageURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            var sessions: [SessionInfo] = []

            for fileURL in files where fileURL.pathExtension == "jsonl" {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                let lines = content.split(separator: "\n")

                // Parse first line for metadata
                guard let firstLine = lines.first else { continue }
                let startEvent = try decoder.decode(SessionEvent.self, from: Data(firstLine.utf8))

                guard let metadata = startEvent.config else { continue }

                let messageCount = lines.count - 2  // Exclude start/end events

                sessions.append(SessionInfo(
                    filename: fileURL.lastPathComponent,
                    timestamp: startEvent.timestamp,
                    messageCount: max(0, messageCount),
                    config: metadata
                ))
            }

            // Sort by timestamp, newest first
            return sessions.sorted { $0.timestamp > $1.timestamp }

        } catch {
            logger.error("Failed to list sessions: \(error)")
            return []
        }
    }

    /// Get current session info
    func getCurrentSessionInfo() -> String? {
        guard let fileURL = currentSessionFile else { return nil }
        return fileURL.lastPathComponent
    }

    /// End current session
    func endSession(messageCount: Int) {
        let event = SessionEvent(
            timestamp: Date(),
            type: .sessionEnd,
            reason: "user_exit",
            messageCount: messageCount
        )
        appendEvent(event)

        logger.info("Ended session: \(messageCount) messages")
        currentSessionFile = nil
    }

    /// Clean up old sessions based on retention policy
    func cleanupOldSessions() {
        guard config.retentionDays > 0 else { return }

        let cutoffDate = Date().addingTimeInterval(-Double(config.retentionDays) * 86400)
        let sessions = listSessions()

        var deletedCount = 0
        for session in sessions where session.timestamp < cutoffDate {
            let fileURL = storageURL.appendingPathComponent(session.filename)
            do {
                try FileManager.default.removeItem(at: fileURL)
                deletedCount += 1
            } catch {
                logger.error("Failed to delete old session: \(error)")
            }
        }

        if deletedCount > 0 {
            logger.info("Cleaned up \(deletedCount) old sessions")
        }
    }
}
```

### 4. Extend MetaCommandHandler

Add session commands to `Sources/YBS/Agent/MetaCommandHandler.swift`:

```swift
// In MetaCommandHandler class, add:

private let sessionManager: SessionManager?

init(toolExecutor: ToolExecutor, logger: Logger, sessionManager: SessionManager? = nil) {
    self.toolExecutor = toolExecutor
    self.logger = logger
    self.sessionManager = sessionManager
}

// In handleCommand switch statement, add new cases:

case "sessions":
    displaySessions()
    return true

case "load":
    handleLoadCommand(Array(parts.dropFirst()), context: &context)
    return true

case "save":
    handleSaveCommand(Array(parts.dropFirst()))
    return true

case "session":
    displayCurrentSession()
    return true

// Add implementation methods:

/// Display all available sessions
private func displaySessions() {
    guard let manager = sessionManager else {
        print("\n❌ Session management not available\n")
        return
    }

    let sessions = manager.listSessions()

    if sessions.isEmpty {
        print("\nNo saved sessions found\n")
        return
    }

    print("\n📁 Available Sessions:")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    for (index, session) in sessions.enumerated() {
        print("  \(index + 1). \(session.displayName)")
        print("     \(session.age) • \(session.messageCount) messages")
        print("     \(session.config.provider)/\(session.config.model)")
        print()
    }
}

/// Load a session by filename or number
private func handleLoadCommand(_ args: [String.SubSequence], context: inout ConversationContext?) {
    guard let manager = sessionManager else {
        print("\n❌ Session management not available\n")
        return
    }

    guard let arg = args.first else {
        print("\n❌ Usage: /load <session-name> or /load <number>\n")
        return
    }

    let sessions = manager.listSessions()
    let filename: String

    // Check if arg is a number (list index)
    if let index = Int(arg), index > 0, index <= sessions.count {
        filename = sessions[index - 1].filename
    } else {
        filename = String(arg)
    }

    do {
        let loadedContext = try manager.loadSession(filename)
        context = loadedContext

        print("\n✅ Loaded session: \(filename)")
        print("   Restored \(loadedContext.getStats().messageCount) messages\n")
    } catch {
        print("\n❌ Failed to load session: \(error)\n")
    }
}

/// Save current session with custom name
private func handleSaveCommand(_ args: [String.SubSequence]) {
    guard let manager = sessionManager else {
        print("\n❌ Session management not available\n")
        return
    }

    guard let name = args.first else {
        print("\n❌ Usage: /save <name>\n")
        return
    }

    do {
        try manager.saveSessionAs(String(name))
        print("\n✅ Session saved as: \(name).jsonl\n")
    } catch {
        print("\n❌ Failed to save session: \(error)\n")
    }
}

/// Display current session info
private func displayCurrentSession() {
    guard let manager = sessionManager else {
        print("\n❌ Session management not available\n")
        return
    }

    if let filename = manager.getCurrentSessionInfo() {
        print("\n📝 Current Session: \(filename)\n")
    } else {
        print("\n❌ No active session\n")
    }
}
```

### 5. Update AgentLoop

Modify `Sources/YBS/Agent/AgentLoop.swift` to integrate SessionManager:

```swift
// Add property:
private let sessionManager: SessionManager

// Update init:
init(config: YBSConfig, logger: Logger) {
    // ... existing init code ...

    // Initialize session manager
    self.sessionManager = SessionManager(config: config.session, logger: logger)

    // Pass session manager to meta command handler
    self.metaCommandHandler = MetaCommandHandler(
        toolExecutor: toolExecutor,
        logger: logger,
        sessionManager: sessionManager
    )
}

// Update run() method:
func run() async {
    // Start new session
    let sessionFile = sessionManager.startNewSession(llmConfig: config.llm)

    logger.info("YBS Agent starting...")
    displayWelcome()

    print("Session: \(sessionFile.lastPathComponent)\n")

    // Add system prompt
    context.addMessage(Message(role: .system, content: systemPrompt))
    sessionManager.appendEvent(SessionEvent(
        timestamp: Date(),
        type: .system,
        content: systemPrompt
    ))

    while true {
        // ... existing loop code ...

        // Log user message
        sessionManager.appendEvent(SessionEvent(
            timestamp: Date(),
            type: .user,
            content: userInput
        ))

        // ... process message ...
    }

    // End session on exit
    let stats = context.getStats()
    sessionManager.endSession(messageCount: stats.messageCount)
    sessionManager.cleanupOldSessions()
}

// Update processWithTools() to log assistant responses and tool calls
```

### 6. Update Help Text

Modify the displayHelp() method in MetaCommandHandler to include session commands:

```swift
Session Management:
  /sessions            List all saved sessions
  /load <session>      Load a previous session
  /save <name>         Save current session with custom name
  /session             Show current session info
```

### 7. Update YBSError

Add session error case to `Sources/YBS/Core/YBSError.swift`:

```swift
case sessionError(message: String)
```

## Verification Criteria

- [ ] SessionConfig added to configuration schema
- [ ] SessionEvent and SessionInfo models created
- [ ] SessionManager class implemented with all methods
- [ ] Meta-commands added: /sessions, /load, /save, /session
- [ ] AgentLoop integrates SessionManager
- [ ] Session directory created with correct permissions (700)
- [ ] `swift build` completes successfully
- [ ] No compilation errors

### Manual Testing (Optional)

1. Run application, verify session file is created
2. Send a few messages, quit
3. Start application again, use `/sessions` to see saved session
4. Use `/load 1` to load the session
5. Verify conversation context is restored
6. Use `/save test-session` to save with custom name
7. Verify saved session appears in `/sessions` list

## Common Issues

1. **File permissions error**: Ensure storage directory is created with mode 700
2. **JSONL parsing error**: Ensure each line is valid JSON
3. **Session not found**: Check that filename includes .jsonl or logic handles both
4. **Context not restored**: Verify all message types are handled in loadSession()

## Rollback Plan

If implementation fails:
1. Comment out SessionManager integration in AgentLoop
2. Remove session meta-commands from MetaCommandHandler
3. System will work without session persistence
4. Can return to implement in next iteration

## Documentation

Create completion record: `docs/build-history/ybs-step_d1e2f3a4b5c6-DONE.txt`

Document:
- Objectives achieved
- Files created/modified
- Verification results
- Any issues encountered

## Next Steps

After this step:
- Session persistence will be fully functional
- Users can save and resume conversations
- Automatic session logging enabled
- Old sessions cleaned up automatically

Consider future enhancements:
- Session search/filtering
- Session export/import
- Session merging
- Session analytics

---

**Implementation Note**: This step adds significant value for users who need to resume long-running conversations or maintain conversation history for reference. The file-based approach is simple, transparent, and requires no external dependencies.
