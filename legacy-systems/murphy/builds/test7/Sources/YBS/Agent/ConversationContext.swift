// Implements: Step 16 (Context Management) + ybs-spec.md § 6.3 (Conversation Context) + § 6.4 (Context Statistics)
import Foundation

class ConversationContext {
    private var messages: [Message] = []
    private var maxMessages: Int
    private let logger: Logger

    // Session metadata
    private let sessionId: String
    private let sessionStartTime: Date

    // Pruning history
    private var pruneCount: Int = 0
    private var totalMessagesPruned: Int = 0

    // Provider config (for cost estimation)
    private var providerName: String
    private var modelName: String

    init(maxMessages: Int = 50, logger: Logger, provider: String = "ollama", model: String = "unknown") {
        self.maxMessages = maxMessages
        self.logger = logger
        self.sessionId = UUID().uuidString.prefix(8).lowercased()
        self.sessionStartTime = Date()
        self.providerName = provider
        self.modelName = model
    }

    /// Update provider/model information for cost estimation
    func updateProvider(_ provider: String, model: String) {
        self.providerName = provider
        self.modelName = model
    }

    /// Add a message to the conversation
    func addMessage(_ message: Message) {
        messages.append(message)

        // Prune if exceeding limit
        if messages.count > maxMessages {
            pruneOldMessages()
        }
    }

    /// Add multiple messages
    func addMessages(_ newMessages: [Message]) {
        for message in newMessages {
            addMessage(message)
        }
    }

    /// Get all messages in conversation
    func getMessages() -> [Message] {
        return messages
    }

    /// Get conversation statistics
    func getStats() -> (messageCount: Int, userTurns: Int, assistantTurns: Int) {
        let userTurns = messages.filter { $0.role == .user }.count
        let assistantTurns = messages.filter { $0.role == .assistant }.count
        return (messages.count, userTurns, assistantTurns)
    }

    /// Clear conversation (keep system prompt if present)
    func clear(keepSystemPrompt: Bool = true) {
        if keepSystemPrompt, let systemMessage = messages.first, systemMessage.role == .system {
            messages = [systemMessage]
        } else {
            messages = []
        }
    }

    /// Prune old messages (keep system + recent messages)
    private func pruneOldMessages() {
        let beforeCount = messages.count
        logger.debug("Pruning old messages (current: \(beforeCount), max: \(maxMessages))")

        // Always keep system prompt
        var systemPrompts: [Message] = []
        var otherMessages: [Message] = []

        for message in messages {
            if message.role == .system {
                systemPrompts.append(message)
            } else {
                otherMessages.append(message)
            }
        }

        // Keep recent messages (leave room for system prompts)
        let keepCount = maxMessages - systemPrompts.count
        let recentMessages = Array(otherMessages.suffix(keepCount))

        // Rebuild messages array
        messages = systemPrompts + recentMessages

        let afterCount = messages.count
        let pruned = beforeCount - afterCount

        if pruned > 0 {
            pruneCount += 1
            totalMessagesPruned += pruned
        }

        logger.info("Pruned conversation (now: \(afterCount) messages, removed: \(pruned))")
    }

    /// Get conversation summary
    func getSummary() -> String {
        let stats = getStats()
        return """
        Conversation Summary:
        - Total messages: \(stats.messageCount)
        - User turns: \(stats.userTurns)
        - Assistant turns: \(stats.assistantTurns)
        """
    }

    // MARK: - Token Estimation and Statistics

    /// Estimate tokens using simple approximation (1 token ≈ 4 characters)
    private func estimateTokens(_ text: String) -> Int {
        return text.count / 4
    }

    /// Get total estimated tokens across all messages
    private func totalContextTokens() -> Int {
        return messages.reduce(0) { sum, msg in
            sum + estimateTokens(msg.content ?? "")
        }
    }

    /// Count messages by role
    private func countMessagesByRole() -> (system: Int, user: Int, assistant: Int, toolCall: Int, toolResult: Int) {
        var system = 0
        var user = 0
        var assistant = 0
        var toolCall = 0
        var toolResult = 0

        for message in messages {
            switch message.role {
            case .system:
                system += 1
            case .user:
                user += 1
            case .assistant:
                assistant += 1
                if let toolCalls = message.toolCalls, !toolCalls.isEmpty {
                    toolCall += toolCalls.count
                }
            case .tool:
                toolResult += 1
            }
        }

        return (system, user, assistant, toolCall, toolResult)
    }

    /// Get tool usage statistics
    private func getToolUsageStats() -> [String: Int] {
        var toolCounts: [String: Int] = [:]

        for message in messages where message.role == .assistant {
            if let toolCalls = message.toolCalls {
                for toolCall in toolCalls {
                    toolCounts[toolCall.function.name, default: 0] += 1
                }
            }
        }

        return toolCounts
    }

    /// Estimate cost based on provider pricing
    private func estimateCost() -> (inputTokens: Int, outputTokens: Int, cost: Double) {
        var inputTokens = 0
        var outputTokens = 0

        for message in messages {
            let tokens = estimateTokens(message.content ?? "")

            switch message.role {
            case .user, .system, .tool:
                inputTokens += tokens  // Input to LLM
            case .assistant:
                outputTokens += tokens  // Output from LLM
            }
        }

        // Provider pricing (per million tokens)
        struct ProviderPricing {
            let inputPricePerMTok: Double
            let outputPricePerMTok: Double
        }

        let pricing: [String: ProviderPricing] = [
            "anthropic": ProviderPricing(inputPricePerMTok: 3.00, outputPricePerMTok: 15.00),
            "openai": ProviderPricing(inputPricePerMTok: 2.50, outputPricePerMTok: 10.00),
            "ollama": ProviderPricing(inputPricePerMTok: 0.00, outputPricePerMTok: 0.00),
            "apple": ProviderPricing(inputPricePerMTok: 0.00, outputPricePerMTok: 0.00)
        ]

        guard let providerPricing = pricing[providerName.lowercased()] else {
            return (inputTokens, outputTokens, 0.0)
        }

        // Calculate cost
        let inputCost = (Double(inputTokens) / 1_000_000.0) * providerPricing.inputPricePerMTok
        let outputCost = (Double(outputTokens) / 1_000_000.0) * providerPricing.outputPricePerMTok
        let totalCost = inputCost + outputCost

        return (inputTokens, outputTokens, totalCost)
    }

    /// Get detailed statistics for /stats command
    func getDetailedStats() -> String {
        let roleCounts = countMessagesByRole()
        let totalMessages = messages.count
        let totalChars = messages.reduce(0) { $0 + ($1.content?.count ?? 0) }
        let totalTokens = totalContextTokens()
        let avgCharsPerMessage = totalMessages > 0 ? totalChars / totalMessages : 0
        let avgTokensPerMessage = totalMessages > 0 ? totalTokens / totalMessages : 0

        // Find largest message
        let largestMessageSize = messages.map { $0.content?.count ?? 0 }.max() ?? 0

        // Calculate session duration
        let duration = Date().timeIntervalSince(sessionStartTime)
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        // Calculate rates
        let messageRate = duration > 0 ? (Double(totalMessages) / duration) * 60.0 : 0.0
        let tokenRate = duration > 0 ? (Double(totalTokens) / duration) * 60.0 : 0.0

        // Get tool usage
        let toolUsage = getToolUsageStats()

        // Get cost estimate
        let (inputTokens, outputTokens, cost) = estimateCost()

        // Format cost display
        let costDisplay: String
        if providerName.lowercased() == "ollama" || providerName.lowercased() == "apple" {
            costDisplay = "$0.00 USD (local/free)"
        } else {
            costDisplay = String(format: "$%.2f USD", cost)
        }

        // Calculate percentage usage
        let messagePercentage = (Double(totalMessages) / Double(maxMessages)) * 100.0

        var output = """
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Conversation Statistics
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Messages:
          • Total: \(totalMessages) messages
          • System: \(roleCounts.system) message\(roleCounts.system == 1 ? "" : "s")
          • User: \(roleCounts.user) message\(roleCounts.user == 1 ? "" : "s")
          • Assistant: \(roleCounts.assistant) message\(roleCounts.assistant == 1 ? "" : "s")
          • Tool calls: \(roleCounts.toolCall) call\(roleCounts.toolCall == 1 ? "" : "s")
          • Tool results: \(roleCounts.toolResult) result\(roleCounts.toolResult == 1 ? "" : "s")
          • Average length: \(avgCharsPerMessage) chars/message
          • Largest message: \(largestMessageSize.formatted()) chars

        Context Size:
          • Characters: \(totalChars.formatted()) chars
          • Estimated tokens: ~\(totalTokens.formatted()) tokens
          • Average tokens/message: ~\(avgTokensPerMessage) tokens
          • Context limit: \(maxMessages) messages
          • Usage: \(String(format: "%.1f", messagePercentage))% of message limit

        Activity:
          • Message rate: \(String(format: "%.1f", messageRate)) messages/min
          • Token rate: ~\(String(format: "%.0f", tokenRate)) tokens/min
          • Context pruned: \(pruneCount) time\(pruneCount == 1 ? "" : "s") (\(totalMessagesPruned) messages removed)

        """

        if !toolUsage.isEmpty {
            output += "Tool Usage:\n"
            for (tool, count) in toolUsage.sorted(by: { $0.key < $1.key }) {
                output += "  • \(tool): \(count) call\(count == 1 ? "" : "s")\n"
            }
            output += "\n"
        }

        output += """
        Session:
          • Session ID: \(sessionId)
          • Started: \(formatDate(sessionStartTime))
          • Duration: \(minutes)m \(seconds)s
          • Provider: \(providerName)
          • Model: \(modelName)

        Cost Estimate:
          • Input tokens: ~\(inputTokens.formatted()) tokens
          • Output tokens: ~\(outputTokens.formatted()) tokens
          • Estimated cost: \(costDisplay)

        """

        return output
    }

    /// Format a date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }

    /// Set context limit (for /context command)
    func setContextLimit(_ newLimit: Int) {
        let oldLimit = self.maxMessages
        let currentCount = messages.count

        self.maxMessages = newLimit

        // If new limit is smaller and we're over it, prune now
        if newLimit < oldLimit && currentCount > newLimit {
            print("⚠️  Context limit reduced: \(oldLimit) → \(newLimit) messages")
            print("   Current: \(currentCount) messages (exceeds limit)")
            print("   Pruning to \(newLimit) most recent messages...")

            pruneOldMessages()

            print("✅ Pruned \(currentCount - messages.count) old messages")
            print("   Current: \(messages.count) messages (100% of limit)")
        } else {
            print("✅ Context limit updated: \(oldLimit) → \(newLimit) messages")
            let percentage = (Double(currentCount) / Double(newLimit)) * 100.0
            print("   Current: \(currentCount) messages (\(Int(percentage))% of limit)")
        }
    }

    /// Get pruning statistics
    func getPruningStats() -> (pruneCount: Int, totalPruned: Int) {
        return (pruneCount, totalMessagesPruned)
    }
}
