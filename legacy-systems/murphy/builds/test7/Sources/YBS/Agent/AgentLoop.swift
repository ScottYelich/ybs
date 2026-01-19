// Implements: Step 14-16 (Agent Loop, Tool Calling, Context) + ybs-spec.md § 6 (Agent Loop)
import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

class AgentLoop {
    private var llmClient: LLMClientProtocol
    private let toolExecutor: ToolExecutor
    private let context: ConversationContext
    private let logger: Logger
    private let systemPrompt: String
    private let metaCommandHandler: MetaCommandHandler
    private let shellInjectionHandler: ShellInjectionHandler
    private var config: YBSConfig
    private let maxToolRounds = 10
    private let inputHandler: InputHandler

    init(config: YBSConfig, logger: Logger) {
        self.config = config
        self.llmClient = LLMClientFactory.createClient(config: config.llm, logger: logger)
        self.toolExecutor = ToolExecutor(logger: logger)
        self.context = ConversationContext(
            maxMessages: config.context.maxMessages,
            logger: logger,
            provider: config.llm.provider,
            model: config.llm.model
        )
        self.logger = logger
        self.systemPrompt = """
        You are a helpful AI coding assistant. You help users with programming tasks.

        You have access to tools for reading files, listing directories, and more.
        Use tools when appropriate to help answer user questions.

        Be concise, accurate, and helpful. If you're unsure, say so.
        """

        // Initialize handlers
        self.metaCommandHandler = MetaCommandHandler(
            toolExecutor: toolExecutor,
            context: context,
            logger: logger
        )
        self.shellInjectionHandler = ShellInjectionHandler(
            toolExecutor: toolExecutor,
            logger: logger,
            maxOutputLength: config.context.maxToolOutputChars
        )

        // Initialize input handler based on config and TTY
        // Check both TTY and TERM environment variable
        let isTTY = isatty(STDIN_FILENO) != 0
        let termType = ProcessInfo.processInfo.environment["TERM"] ?? ""
        let hasValidTerm = !termType.isEmpty && termType != "dumb"

        // Detect SSH sessions (LineNoise often fails over SSH)
        let isSSH = ProcessInfo.processInfo.environment["SSH_CONNECTION"] != nil ||
                    ProcessInfo.processInfo.environment["SSH_CLIENT"] != nil ||
                    ProcessInfo.processInfo.environment["SSH_TTY"] != nil

        if config.ui.enableReadline && isTTY && hasValidTerm && !isSSH {
            #if canImport(LineNoise)
            self.inputHandler = ReadlineInputHandler(
                historyFile: config.ui.historyFile,
                maxEntries: config.ui.historyMaxEntries,
                logger: logger
            )
            logger.info("Readline enabled (history: \(config.ui.historyFile))")
            #else
            self.inputHandler = PlainInputHandler()
            logger.warn("LineNoise not available, using plain input")
            #endif
        } else {
            self.inputHandler = PlainInputHandler()
            if !config.ui.enableReadline {
                logger.info("Readline disabled by configuration")
            } else if !isTTY {
                logger.info("Readline disabled (not a TTY)")
            } else if !hasValidTerm {
                logger.info("Readline disabled (TERM=\(termType) not supported)")
            } else if isSSH {
                logger.info("Readline disabled (SSH session detected)")
            }
        }
    }

    /// Start the interactive agent loop
    func run() async {
        logger.info("YBS Agent starting...")

        // Load external tools
        await toolExecutor.loadExternalTools(toolPaths: config.tools.searchPaths)

        displayWelcome()

        // Add system prompt
        context.addMessage(Message(role: .system, content: systemPrompt))

        while true {
            // Read user input
            guard let userInput = inputHandler.readLine(prompt: "\nYou: "), !userInput.isEmpty else {
                continue
            }

            // Check for quit (handle both with and without slash)
            let normalizedInput = userInput.lowercased()
            if normalizedInput == "quit" || normalizedInput == "exit" ||
               normalizedInput == "/quit" || normalizedInput == "/exit" {
                displayGoodbye()
                break
            }

            // Check for async meta-commands (reload-tools, etc.)
            if await metaCommandHandler.handleAsyncCommand(userInput, config: config) {
                // Async command was handled, don't send to LLM
                continue
            }

            // Check for meta-commands (pass config and client for provider switching)
            if metaCommandHandler.handleCommand(userInput, config: &config, llmClient: &llmClient) {
                // Command was handled, update context with current provider/model info
                context.updateProvider(config.llm.provider, model: config.llm.model)
                continue
            }

            // Check for shell injection
            if shellInjectionHandler.isShellCommand(userInput) {
                let (shouldInject, message) = await shellInjectionHandler.handleShellCommand(userInput)

                if shouldInject {
                    // Inject command output into context
                    context.addMessage(Message(role: .user, content: message))

                    // Let LLM respond to it
                    await processWithTools()
                }
                continue
            }

            // Normal chat message - add to context and process
            context.addMessage(Message(role: .user, content: userInput))
            await processWithTools()
        }

        // Cleanup input handler (save history, etc.)
        inputHandler.cleanup()
    }

    /// Display welcome message
    private func displayWelcome() {
        print("""

        ╔═══════════════════════════════════════════════════════════════╗
        ║  Welcome to test7 - Extensible LLM Chat                       ║
        ║                                                               ║
        ║  Commands:                                                    ║
        ║    /help             - Show available commands                ║
        ║    /tools            - List available tools                   ║
        ║    /stats            - Show conversation statistics           ║
        ║    quit or exit      - Exit application                       ║
        ║                                                               ║
        ║  Type /help for more information                              ║
        ╚═══════════════════════════════════════════════════════════════╝

        """)
    }

    /// Display goodbye message with statistics
    private func displayGoodbye() {
        let stats = context.getStats()

        print("\n\n👋 Goodbye!")
        print("\nSession summary:")
        print("  • Messages: \(stats.messageCount)")
        print("  • User turns: \(stats.userTurns)")
        print("  • Assistant turns: \(stats.assistantTurns)")
        print()
    }

    /// Process user message with tool calling loop
    private func processWithTools() async {
        var toolRound = 0

        while toolRound < maxToolRounds {
            toolRound += 1

            let tools = toolExecutor.toolSchemas()

            print("\nAI: ", terminator: "")
            fflush(stdout)

            do {
                let response = try await llmClient.sendStreamingChatRequest(
                    messages: context.getMessages(),
                    tools: tools
                ) { token in
                    print(token, terminator: "")
                    fflush(stdout)
                }

                print()

                // Add assistant response
                context.addMessage(response)

                if let toolCalls = response.toolCalls, !toolCalls.isEmpty {
                    await executeTools(toolCalls)
                    continue
                } else {
                    break
                }
            } catch {
                logger.error("Failed to get response: \(error)")
                print("\n❌ Error: \(error)")
                break
            }
        }

        if toolRound >= maxToolRounds {
            logger.warn("Max tool rounds reached")
            print("\n⚠️ Maximum tool execution rounds reached")
        }
    }

    private func executeTools(_ toolCalls: [ToolCall]) async {
        for toolCall in toolCalls {
            let toolName = toolCall.function.name
            let toolArgs = toolCall.function.arguments

            logger.info("Executing tool: \(toolName)")
            print("🔧 Using tool: \(toolName)")

            do {
                let result = try await toolExecutor.execute(
                    toolName: toolName,
                    arguments: toolArgs
                )

                let resultContent: String
                if result.success {
                    resultContent = result.output ?? "Success"
                    print("   ✓ Success")
                } else {
                    resultContent = "Error: \(result.error ?? "Unknown")"
                    print("   ✗ Error: \(result.error ?? "unknown")")
                }

                // Add tool result
                context.addMessage(Message(
                    role: .tool,
                    content: resultContent,
                    name: toolName,
                    toolCallId: toolCall.id
                ))
            } catch {
                logger.error("Tool execution failed: \(error)")
                print("   ✗ Error: \(error)")

                context.addMessage(Message(
                    role: .tool,
                    content: "Error: \(error.localizedDescription)",
                    name: toolName,
                    toolCallId: toolCall.id
                ))
            }
        }
    }
}
