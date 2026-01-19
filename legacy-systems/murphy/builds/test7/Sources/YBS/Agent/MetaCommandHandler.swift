// Implements: Step 36 (Meta Commands) + ybs-spec.md § 6.5 (Meta Commands) + § 6.4 (Context Statistics)
import Foundation

/// Handles meta-commands that control the chat session
class MetaCommandHandler {
    private let toolExecutor: ToolExecutor
    private let context: ConversationContext
    private let logger: Logger

    init(toolExecutor: ToolExecutor, context: ConversationContext, logger: Logger) {
        self.toolExecutor = toolExecutor
        self.context = context
        self.logger = logger
    }

    /// Check if input is an async meta-command and handle it
    /// Returns true if input was an async command (don't send to LLM)
    func handleAsyncCommand(
        _ input: String,
        config: YBSConfig
    ) async -> Bool {
        guard input.hasPrefix("/") else {
            return false  // Not a command
        }

        let parts = input.dropFirst().split(separator: " ", maxSplits: 2)
        guard let command = parts.first?.lowercased() else {
            return false
        }

        switch command {
        case "reload-tools", "rescan-tools":
            await reloadTools(config: config)
            return true

        default:
            return false  // Not an async command
        }
    }

    /// Check if input is a meta-command and handle it
    /// Returns true if input was a command (don't send to LLM)
    /// For provider/model commands, pass config and client to update them
    func handleCommand(
        _ input: String,
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) -> Bool {
        guard input.hasPrefix("/") else {
            return false  // Not a command
        }

        let parts = input.dropFirst().split(separator: " ", maxSplits: 2)
        guard let command = parts.first?.lowercased() else {
            return false
        }

        switch command {
        case "help":
            displayHelp()
            return true

        case "tools":
            displayTools()
            return true

        case "stats":
            displayStats()
            return true

        case "context":
            handleContextCommand(Array(parts.dropFirst()))
            return true

        case "provider":
            handleProviderCommand(Array(parts.dropFirst()), config: &config, llmClient: &llmClient)
            return true

        case "model":
            handleModelCommand(Array(parts.dropFirst()), config: &config, llmClient: &llmClient)
            return true

        case "config":
            displayConfig(config)
            return true

        case "quit", "exit":
            // Already handled by AgentLoop, but include for completeness
            return false

        default:
            logger.warn("Unknown command: /\(command)")
            print("\n❌ Unknown command: /\(command)")
            print("Type /help for available commands\n")
            return true  // Still consumed as command attempt
        }
    }

    /// Reload external tools from configured paths
    private func reloadTools(config: YBSConfig) async {
        print("\n🔄 Rescanning for external tools...")
        print("Paths: \(config.tools.searchPaths.joined(separator: ", "))\n")

        await toolExecutor.loadExternalTools(toolPaths: config.tools.searchPaths)

        let tools = toolExecutor.toolSchemas()
        let builtinCount = 6  // read_file, list_files, write_file, edit_file, search_files, run_shell
        let externalCount = tools.count - builtinCount

        print("✅ Tool reload complete!")
        print("   Built-in tools: \(builtinCount)")
        print("   External tools: \(externalCount)")
        print("   Total: \(tools.count) tools available\n")

        if externalCount > 0 {
            print("External tools loaded:")
            for tool in tools {
                let name = tool.function.name
                if !["read_file", "list_files", "write_file", "edit_file", "search_files", "run_shell"].contains(name) {
                    print("  • \(name): \(tool.function.description)")
                }
            }
            print()
        }
    }

    // MARK: - Command Implementations

    /// Display help message
    private func displayHelp() {
        print("""

        📖 Available Commands:
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Meta Commands:
          /help                Show this help message
          /tools               List available tools with descriptions
          /stats               Show conversation statistics and cost estimate
          /context <limit>     Adjust context limit (number of messages)
          /reload-tools        Rescan and reload external tools
          /provider [name]     Show or switch LLM provider
          /model [name]        Show or switch LLM model
          /config              Show current configuration
          /quit or /exit       Exit the application

        Shell Injection:
          !<command>           Run shell command and inject output into context

        Examples:
          /tools               Show all available tools
          /stats               Display conversation statistics
          /context 100         Set context limit to 100 messages
          /provider            Show current provider and available options
          /provider anthropic  Switch to Anthropic Claude
          /model gpt-4o        Switch to GPT-4o model
          /config              Display current configuration
          !ls -la              List files in current directory
          !cat README.md       Show README contents
          !git status          Show git status
          quit                 Exit (can also use 'exit' or '/quit')

        Tips:
        - Ask the AI to use tools: "Read the README file"
        - Tools are invoked automatically by the AI when needed
        - Shell commands (!cmd) show output, then AI responds
        - Provider switching happens instantly without restart
        - Commands respect sandbox settings
        - Large outputs are truncated automatically
        - Use /stats to track token usage and estimated costs

        Security:
        - Shell commands run in sandbox (if enabled in config)
        - Dangerous commands are blocked
        - Commands timeout after 60 seconds

        Note: Commands starting with / are NOT sent to the LLM.
              Commands starting with ! are executed, then output sent to LLM.

        """)
    }

    /// Display all available tools
    private func displayTools() {
        let tools = toolExecutor.toolSchemas()

        print("\n🔧 Available Tools:\n")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

        if tools.isEmpty {
            print("  No tools available\n")
            return
        }

        // Sort tools by name for consistent display
        let sortedTools = tools.sorted(by: { (t1: Tool, t2: Tool) -> Bool in
            t1.function.name < t2.function.name
        })

        for tool in sortedTools {
            print("  \(tool.function.name)")
            print("    \(tool.function.description)")

            // Show parameters if present
            let params = tool.function.parameters
            let required = params.required
            let properties = params.properties

            if !properties.isEmpty {
                print("    Parameters:")
                for (name, prop) in properties.sorted(by: { $0.key < $1.key }) {
                    let requiredMark = required.contains(name) ? "*" : ""
                    print("      - \(name)\(requiredMark): \(prop.description)")
                }
            }

            print()
        }

        print("Total: \(tools.count) tools available")
        print("(*) = required parameter\n")
    }

    /// Handle /provider command to switch LLM provider
    private func handleProviderCommand(
        _ args: [String.SubSequence],
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) {
        var cfg = config

        // No args - show current provider and available options
        if args.isEmpty {
            print("\n🔧 Current provider: \(cfg.llm.provider)")
            print("\nAvailable providers:")
            for provider in ProviderDefaults.supportedProviders {
                let info = ProviderDefaults.info(for: provider)
                let current = provider.lowercased() == cfg.llm.provider.lowercased() ? " ← current" : ""
                print("  • \(provider): \(info)\(current)")
            }
            print("\nUsage: /provider <name>")
            print("Example: /provider anthropic\n")
            return
        }

        let newProvider = String(args[0]).lowercased()

        // Validate provider
        if !ProviderDefaults.supportedProviders.contains(newProvider) {
            print("\n❌ Unknown provider: \(newProvider)")
            print("Available providers: \(ProviderDefaults.supportedProviders.joined(separator: ", "))\n")
            return
        }

        // Check API key requirement
        if ProviderDefaults.requiresAPIKey(newProvider) && cfg.llm.apiKey == nil {
            print("\n❌ Provider '\(newProvider)' requires an API key")
            print("Please set API key in config or environment variable\n")
            return
        }

        // Update config
        cfg.llm.provider = newProvider
        cfg.llm.endpoint = ProviderDefaults.endpoint(for: newProvider)
        cfg.llm.model = ProviderDefaults.model(for: newProvider)

        // Create new client
        llmClient = LLMClientFactory.createClient(config: cfg.llm, logger: logger)
        config = cfg

        print("\n✅ Switched to provider: \(newProvider)")
        print("   Endpoint: \(cfg.llm.endpoint)")
        print("   Model: \(cfg.llm.model)\n")

        logger.info("Switched LLM provider to: \(newProvider)")
    }

    /// Handle /model command to switch model within current provider
    private func handleModelCommand(
        _ args: [String.SubSequence],
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) {
        var cfg = config

        // No args - show current model
        if args.isEmpty {
            print("\n🔧 Current configuration:")
            print("   Provider: \(cfg.llm.provider)")
            print("   Model: \(cfg.llm.model)")
            print("\nUsage: /model <model-name>")
            print("Example: /model gpt-4o\n")
            return
        }

        let newModel = String(args[0])

        // Update config
        cfg.llm.model = newModel

        // Create new client with updated model
        llmClient = LLMClientFactory.createClient(config: cfg.llm, logger: logger)
        config = cfg

        print("\n✅ Switched to model: \(newModel)")
        print("   Provider: \(cfg.llm.provider)\n")

        logger.info("Switched LLM model to: \(newModel)")
    }

    /// Display current configuration
    private func displayConfig(_ config: YBSConfig) {
        print("\n⚙️  Current Configuration:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("\nLLM:")
        print("  Provider: \(config.llm.provider)")
        print("  Model: \(config.llm.model)")
        print("  Endpoint: \(config.llm.endpoint)")
        print("  Temperature: \(config.llm.temperature)")
        print("  Max tokens: \(config.llm.maxTokens)")
        print("  API key: \(config.llm.apiKey != nil ? "Set" : "Not set")")

        print("\nContext:")
        print("  Max messages: \(config.context.maxMessages)")
        print("  Max tool output: \(config.context.maxToolOutputChars) chars")

        print("\nSafety:")
        print("  Sandbox enabled: \(config.safety.sandboxEnabled)")
        print("  Blocked commands: \(config.safety.blockedCommands.joined(separator: ", "))")

        print("\nTools:")
        let toolCount = toolExecutor.toolSchemas().count
        print("  Registered: \(toolCount) tools")
        print("\n")
    }

    /// Display conversation statistics
    private func displayStats() {
        print("\n\(context.getDetailedStats())")
    }

    /// Handle /context command to adjust context limit
    private func handleContextCommand(_ args: [String.SubSequence]) {
        // No args - show usage
        if args.isEmpty {
            let stats = context.getStats()
            print("\n📊 Current context status:")
            print("   Messages in context: \(stats.messageCount)")
            print("\nUsage: /context <limit>")
            print("Example: /context 100\n")
            return
        }

        // Parse limit
        guard let limitStr = args.first,
              let newLimit = Int(limitStr),
              newLimit > 0 else {
            print("\n❌ Invalid limit. Must be a positive number.")
            print("Usage: /context <limit>")
            print("Example: /context 100\n")
            return
        }

        // Update limit
        print()
        context.setContextLimit(newLimit)
        print()
    }
}
