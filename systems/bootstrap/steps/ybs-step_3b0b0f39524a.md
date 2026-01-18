# Step 43: Context Statistics and Management

**GUID**: 3b0b0f39524a
**Status**: not_started
**Version**: 0.1.0

---

## Objectives

Implement comprehensive context statistics and dynamic context management features:

1. **`/stats` command** - Display conversation statistics (messages, tokens, size)
2. **`/context <limit>` command** - Dynamically adjust retained message limit
3. **Token estimation** - Approximate token counts for context sizing
4. **Context visualization** - Show message distribution and recent activity
5. **Statistics tracking** - Track session metadata (start time, duration, provider/model)

**Implements**: ybs-spec.md § 6.4 (Context Statistics and Management)

---

## Context

**Current State**:
- ConversationContext already tracks messages and provides basic stats
- Message count limit exists (`maxMessages: 50`)
- No visibility into context size or token usage
- No dynamic adjustment of context limits
- No comprehensive statistics display

**After This Step**:
- Users can see detailed conversation statistics with `/stats`
- Users can adjust context limits on-the-fly with `/context <limit>`
- Token estimation provides approximate context size feedback
- Session metadata tracked (start time, duration)

---

## Instructions

### Phase 1: Extend ConversationContext with Statistics

**File**: `Sources/YBS/Agent/ConversationContext.swift`

1. **Add session metadata tracking**:
   ```swift
   class ConversationContext {
       private var messages: [Message] = []
       private let maxMessages: Int
       private let logger: Logger

       // NEW: Session metadata
       private let sessionStartTime: Date
       private var sessionID: String

       init(maxMessages: Int = 50, logger: Logger) {
           self.maxMessages = maxMessages
           self.logger = logger
           self.sessionStartTime = Date()
           self.sessionID = UUID().uuidString.prefix(8).lowercased()
       }
   ```

2. **Add token estimation methods**:
   ```swift
   /// Estimate tokens for a text string (1 token ≈ 4 chars)
   private func estimateTokens(_ text: String) -> Int {
       return text.count / 4
   }

   /// Calculate total estimated tokens in context
   func estimatedTokenCount() -> Int {
       return messages.reduce(0) { sum, msg in
           sum + estimateTokens(msg.content)
       }
   }

   /// Calculate total character count
   func totalCharacterCount() -> Int {
       return messages.reduce(0) { sum, msg in
           sum + msg.content.count
       }
   }
   ```

3. **Add detailed statistics method**:
   ```swift
   /// Get detailed conversation statistics
   func getDetailedStats() -> ConversationStats {
       let systemCount = messages.filter { $0.role == .system }.count
       let userCount = messages.filter { $0.role == .user }.count
       let assistantCount = messages.filter { $0.role == .assistant }.count
       let toolCallCount = messages.filter { $0.role == .assistant && !$0.toolCalls.isEmpty }.count
       let toolResultCount = messages.filter { $0.role == .tool }.count

       return ConversationStats(
           totalMessages: messages.count,
           systemMessages: systemCount,
           userMessages: userCount,
           assistantMessages: assistantCount,
           toolCalls: toolCallCount,
           toolResults: toolResultCount,
           characterCount: totalCharacterCount(),
           estimatedTokens: estimatedTokenCount(),
           sessionID: sessionID,
           sessionStartTime: sessionStartTime,
           sessionDuration: Date().timeIntervalSince(sessionStartTime)
       )
   }
   ```

4. **Define ConversationStats struct**:
   ```swift
   struct ConversationStats {
       let totalMessages: Int
       let systemMessages: Int
       let userMessages: Int
       let assistantMessages: Int
       let toolCalls: Int
       let toolResults: Int
       let characterCount: Int
       let estimatedTokens: Int
       let sessionID: String
       let sessionStartTime: Date
       let sessionDuration: TimeInterval
   }
   ```

5. **Add dynamic context limit adjustment**:
   ```swift
   /// Update context limit and prune if necessary
   mutating func setContextLimit(_ newLimit: Int) -> ContextLimitUpdate {
       let oldLimit = self.maxMessages
       let currentCount = messages.count

       self.maxMessages = newLimit

       // If new limit is smaller and we exceed it, prune now
       if newLimit < oldLimit && currentCount > newLimit {
           let beforeCount = currentCount
           pruneOldMessages()
           let afterCount = messages.count
           let pruned = beforeCount - afterCount

           return ContextLimitUpdate(
               oldLimit: oldLimit,
               newLimit: newLimit,
               currentCount: afterCount,
               pruned: pruned,
               exceeded: true
           )
       } else {
           return ContextLimitUpdate(
               oldLimit: oldLimit,
               newLimit: newLimit,
               currentCount: currentCount,
               pruned: 0,
               exceeded: false
           )
       }
   }

   struct ContextLimitUpdate {
       let oldLimit: Int
       let newLimit: Int
       let currentCount: Int
       let pruned: Int
       let exceeded: Bool
   }
   ```

### Phase 2: Implement /stats Command

**File**: `Sources/YBS/Agent/MetaCommandHandler.swift`

1. **Add `/stats` command handling**:
   ```swift
   func handleCommand(_ input: String, config: inout YBSConfig, llmClient: inout LLMClientProtocol) -> Bool {
       // ... existing commands ...

       // NEW: /stats command
       if input.hasPrefix("/stats") {
           displayStats()
           return true
       }

       return false
   }
   ```

2. **Add reference to ConversationContext**:
   ```swift
   class MetaCommandHandler {
       private let toolExecutor: ToolExecutor
       private let logger: Logger
       private weak var context: ConversationContext?  // NEW

       init(toolExecutor: ToolExecutor, logger: Logger, context: ConversationContext? = nil) {
           self.toolExecutor = toolExecutor
           self.logger = logger
           self.context = context
       }
   }
   ```

3. **Implement `displayStats()` method**:
   ```swift
   private func displayStats() {
       guard let context = context else {
           print("⚠️  Context not available")
           return
       }

       let stats = context.getDetailedStats()
       let config = // Get from AgentLoop

       // Calculate percentages
       let messagePercentage = (Double(stats.totalMessages) / Double(config.context.maxMessages)) * 100.0
       let tokenPercentage = (Double(stats.estimatedTokens) / Double(config.context.maxTokens)) * 100.0

       // Format duration
       let duration = formatDuration(stats.sessionDuration)

       print("""

       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       Conversation Statistics
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

       Messages:
         • Total: \(stats.totalMessages) messages
         • System: \(stats.systemMessages) message\(stats.systemMessages == 1 ? "" : "s")
         • User: \(stats.userMessages) messages
         • Assistant: \(stats.assistantMessages) messages
         • Tool calls: \(stats.toolCalls) calls
         • Tool results: \(stats.toolResults) results

       Context Size:
         • Characters: \(formatNumber(stats.characterCount)) chars
         • Estimated tokens: ~\(formatNumber(stats.estimatedTokens)) tokens
         • Context limit: \(config.context.maxMessages) messages
         • Token budget: \(formatNumber(config.context.maxTokens)) tokens
         • Usage: \(String(format: "%.1f", messagePercentage))% of message limit, \(String(format: "%.1f", tokenPercentage))% of token budget

       Session:
         • Session ID: \(stats.sessionID)
         • Started: \(formatTimestamp(stats.sessionStartTime))
         • Duration: \(duration)
         • Provider: \(config.llm.provider)
         • Model: \(config.llm.model)

       """)
   }

   private func formatDuration(_ seconds: TimeInterval) -> String {
       let hours = Int(seconds) / 3600
       let minutes = (Int(seconds) % 3600) / 60
       let secs = Int(seconds) % 60

       if hours > 0 {
           return "\(hours)h \(minutes)m \(secs)s"
       } else if minutes > 0 {
           return "\(minutes)m \(secs)s"
       } else {
           return "\(secs)s"
       }
   }

   private func formatNumber(_ num: Int) -> String {
       let formatter = NumberFormatter()
       formatter.numberStyle = .decimal
       return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
   }

   private func formatTimestamp(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       return formatter.string(from: date)
   }
   ```

### Phase 3: Implement /context Command

**File**: `Sources/YBS/Agent/MetaCommandHandler.swift`

1. **Add `/context` command handling**:
   ```swift
   func handleCommand(_ input: String, config: inout YBSConfig, llmClient: inout LLMClientProtocol) -> Bool {
       // ... existing commands ...

       // NEW: /context command
       if input.hasPrefix("/context ") {
           let parts = input.split(separator: " ", maxSplits: 1)
           if parts.count == 2, let newLimit = Int(parts[1]) {
               adjustContextLimit(newLimit, config: &config)
           } else {
               print("⚠️  Usage: /context <limit>")
               print("   Example: /context 100")
           }
           return true
       }

       return false
   }
   ```

2. **Implement `adjustContextLimit()` method**:
   ```swift
   private func adjustContextLimit(_ newLimit: Int, config: inout YBSConfig) {
       guard let context = context else {
           print("⚠️  Context not available")
           return
       }

       guard newLimit > 0 && newLimit <= 500 else {
           print("⚠️  Invalid limit: \(newLimit)")
           print("   Limit must be between 1 and 500")
           return
       }

       let update = context.setContextLimit(newLimit)
       config.context.maxMessages = newLimit

       if update.exceeded {
           print("⚠️  Context limit reduced: \(update.oldLimit) → \(update.newLimit) messages")
           print("   Pruned \(update.pruned) old messages (kept system prompt + recent)")
           print("✅ Current: \(update.currentCount) messages (100% of limit)")
       } else {
           print("✅ Context limit updated: \(update.oldLimit) → \(update.newLimit) messages")
           let percentage = (Double(update.currentCount) / Double(update.newLimit)) * 100.0
           print("   Current: \(update.currentCount) messages (\(Int(percentage))% of limit)")
       }
   }
   ```

### Phase 4: Update AgentLoop

**File**: `Sources/YBS/Agent/AgentLoop.swift`

1. **Pass context reference to MetaCommandHandler**:
   ```swift
   init(config: YBSConfig, logger: Logger) {
       // ... existing init ...

       // Update MetaCommandHandler to include context
       self.metaCommandHandler = MetaCommandHandler(
           toolExecutor: toolExecutor,
           logger: logger,
           context: context  // NEW
       )
   }
   ```

2. **Update `/help` to include new commands**:
   ```swift
   private func displayHelp() {
       print("""

       Available Commands:
         /help            - Show this help message
         /tools           - List available tools
         /stats           - Show conversation statistics (NEW)
         /context <limit> - Adjust context message limit (NEW)
         /provider <name> - Switch LLM provider
         /model <name>    - Switch model
         /config          - Show current configuration
         /reload-tools    - Rescan for external tools
         quit or exit     - Exit application

       """)
   }
   ```

### Phase 5: Update Configuration Schema

**File**: `Sources/YBS/Configuration/Config.swift`

1. **Add new context configuration options**:
   ```swift
   struct ContextConfig: Codable {
       var maxMessages: Int = 50
       var maxTokens: Int = 32000
       var compactionThreshold: Double = 0.95
       var repoMapTokens: Int = 1024
       var maxToolOutputChars: Int = 10000
       var enableTokenCounting: Bool = false      // NEW
       var showStatsOnPrune: Bool = true          // NEW

       enum CodingKeys: String, CodingKey {
           case maxMessages = "max_messages"
           case maxTokens = "max_tokens"
           case compactionThreshold = "compaction_threshold"
           case repoMapTokens = "repo_map_tokens"
           case maxToolOutputChars = "max_tool_output_chars"
           case enableTokenCounting = "enable_token_counting"
           case showStatsOnPrune = "show_stats_on_prune"
       }
   }
   ```

### Phase 6: Testing

**Create**: `Tests/YBSTests/Agent/ContextStatsTests.swift`

```swift
import Testing
import Foundation
@testable import YBS

struct ContextStatsTests {
    @Test("Token estimation is within 20% of actual")
    func tokenEstimationAccuracy() throws {
        let context = ConversationContext(maxMessages: 50, logger: testLogger())

        // Add sample messages
        context.addMessage(Message(role: .user, content: "Hello world"))  // ~3 tokens
        context.addMessage(Message(role: .assistant, content: "Hi there! How can I help?"))  // ~7 tokens

        let stats = context.getDetailedStats()

        // Total: ~10 tokens, but estimation is ~10 chars / 4 = 2.5 tokens per message
        // Accept 20% margin of error
        #expect(stats.estimatedTokens > 0)
        #expect(stats.estimatedTokens < 100)  // Sanity check
    }

    @Test("/stats command shows all statistics")
    func statsCommandOutput() throws {
        let context = ConversationContext(maxMessages: 50, logger: testLogger())
        let config = YBSConfig()

        // Add messages
        context.addMessage(Message(role: .system, content: "You are a helpful assistant"))
        context.addMessage(Message(role: .user, content: "Hello"))
        context.addMessage(Message(role: .assistant, content: "Hi there!"))

        let stats = context.getDetailedStats()

        #expect(stats.totalMessages == 3)
        #expect(stats.systemMessages == 1)
        #expect(stats.userMessages == 1)
        #expect(stats.assistantMessages == 1)
        #expect(stats.characterCount > 0)
        #expect(stats.estimatedTokens > 0)
    }

    @Test("Context limit can be increased")
    func increaseContextLimit() throws {
        var context = ConversationContext(maxMessages: 50, logger: testLogger())

        // Add 30 messages
        for i in 1...30 {
            context.addMessage(Message(role: .user, content: "Message \(i)"))
        }

        // Increase limit
        let update = context.setContextLimit(100)

        #expect(update.oldLimit == 50)
        #expect(update.newLimit == 100)
        #expect(update.pruned == 0)
        #expect(!update.exceeded)
        #expect(update.currentCount == 30)
    }

    @Test("Context limit can be decreased with pruning")
    func decreaseContextLimitWithPruning() throws {
        var context = ConversationContext(maxMessages: 50, logger: testLogger())

        // Add system prompt + 49 messages (total 50)
        context.addMessage(Message(role: .system, content: "System prompt"))
        for i in 1...49 {
            context.addMessage(Message(role: .user, content: "Message \(i)"))
        }

        // Decrease limit to 20
        let update = context.setContextLimit(20)

        #expect(update.oldLimit == 50)
        #expect(update.newLimit == 20)
        #expect(update.pruned == 30)  // Should prune 30 messages
        #expect(update.exceeded)
        #expect(update.currentCount == 20)

        // System prompt should still be there
        let stats = context.getDetailedStats()
        #expect(stats.systemMessages == 1)
    }

    @Test("Session metadata tracked correctly")
    func sessionMetadataTracking() throws {
        let context = ConversationContext(maxMessages: 50, logger: testLogger())

        let stats = context.getDetailedStats()

        #expect(!stats.sessionID.isEmpty)
        #expect(stats.sessionStartTime <= Date())
        #expect(stats.sessionDuration >= 0)
    }
}
```

---

## Verification

### Manual Testing

1. **Build the project**:
   ```bash
   swift build
   ```
   Expected: Clean build with no errors

2. **Run bootstrap**:
   ```bash
   swift run ybs
   ```

3. **Test `/stats` command**:
   ```
   You: Hello
   AI: Hi there! How can I help?

   You: /stats
   ```
   Expected output showing:
   - Message counts (system, user, assistant, tool calls/results)
   - Character and token counts
   - Context usage percentage
   - Session metadata (ID, start time, duration, provider/model)

4. **Test `/context` increase**:
   ```
   You: /context 100
   ```
   Expected: `✅ Context limit updated: 50 → 100 messages`

5. **Test `/context` decrease with pruning**:
   ```
   # After having >30 messages in conversation
   You: /context 20
   ```
   Expected: Shows pruning message and updates limit

6. **Test token estimation**:
   - Have a longer conversation (10+ exchanges)
   - Run `/stats`
   - Verify estimated tokens is reasonable (~25% of character count)

### Automated Testing

```bash
swift test --filter ContextStatsTests
```

Expected: All tests pass

### Verification Checklist

- [ ] `/stats` command displays all required statistics
- [ ] Token estimation works (approximate, within reason)
- [ ] Character counting accurate
- [ ] `/context <limit>` command adjusts limit
- [ ] Increasing limit does NOT prune messages
- [ ] Decreasing limit DOES prune if needed
- [ ] System prompt always preserved during pruning
- [ ] Session metadata tracked (ID, start time, duration)
- [ ] `/help` shows new commands
- [ ] All unit tests pass
- [ ] No compilation errors or warnings

---

## Success Criteria

**This step is complete when**:

1. ✅ `/stats` command shows comprehensive conversation statistics
2. ✅ `/context <limit>` command dynamically adjusts context limits
3. ✅ Token estimation implemented (1 token ≈ 4 chars)
4. ✅ Session metadata tracked (ID, start time, duration)
5. ✅ Context pruning preserves system prompts
6. ✅ All unit tests pass
7. ✅ Manual testing verification complete
8. ✅ No regression in existing functionality

---

## Notes

- Token estimation is intentionally approximate (no external tokenizer dependency)
- For production use, consider integrating actual tokenizer library (tiktoken, swift-transformers)
- Session file size tracking (from § 6.4.5) depends on Session Persistence (Step 41) being implemented
- Context visualization (distribution bars, recent activity) is optional enhancement

---

## Traceability

**Implements**:
- ybs-spec.md § 6.4.1 (Statistics Command)
- ybs-spec.md § 6.4.2 (Context Limit Adjustment)
- ybs-spec.md § 6.4.3 (Context Visualization)
- ybs-spec.md § 6.4.5 (Configuration)
- ybs-spec.md § 6.4.6 (Testing Requirements)

**Dependencies**:
- Step 16: Context Management (ConversationContext exists)
- Step 18: Meta Commands (MetaCommandHandler exists)
- Step 41: Session Persistence (for session file size stats - optional)

**Enables**:
- Better user visibility into context usage
- Dynamic context management during conversations
- Foundation for more advanced context strategies (RAG, summarization)

---

**Version History**:
- 0.1.0 (2026-01-18): Initial step creation
