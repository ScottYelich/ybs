// Implements: Step 8 (CLI Argument Parsing) + ybs-spec.md § 2.2 (Command Line Interface)
import Foundation
import ArgumentParser

@main
struct YBSCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "test7",
        abstract: "test7 - AI-powered coding assistant",
        version: "0.1.0"
    )

    @Option(name: .shortAndLong, help: "Path to configuration file")
    var config: String?

    @Option(name: .shortAndLong, help: "Override LLM model")
    var model: String?

    @Option(name: .shortAndLong, help: "Override LLM provider (ollama, openai, anthropic)")
    var provider: String?

    @Option(help: "Override LLM API endpoint URL")
    var endpoint: String?

    @Flag(name: .long, help: "Show what would happen without executing")
    var dryRun: Bool = false

    @Flag(name: .long, help: "Disable colored output")
    var noColor: Bool = false

    @Flag(name: .long, help: "Disable sandboxing (DANGEROUS)")
    var noSandbox: Bool = false

    @Flag(name: .long, help: "Disable readline (use plain input)")
    var noReadline: Bool = false

    @Flag(name: .long, help: "Show token usage statistics")
    var showTokens: Bool = false

    @Flag(name: .long, help: "Show tool calls in output")
    var showTools: Bool = false

    @Flag(name: .long, help: "Disable console logging (clean chat interface)")
    var quiet: Bool = false

    @Flag(name: .long, help: "Enable verbose console logging (show debug messages)")
    var verbose: Bool = false

    func run() throws {
        // Initialize file logging (before any log messages)
        Logger.initializeFileLogging()

        // Load base configuration from files
        var config = ConfigLoader.loadStandard()

        // Apply CLI overrides for logging first (before any log messages)
        if quiet {
            config.ui.consoleLogLevel = "none"
        }
        if verbose {
            config.ui.consoleLogLevel = "debug"
        }

        // Set console log level from config (after CLI overrides)
        Logger.setConsoleLogLevel(config.ui.consoleLogLevel)

        // Apply other CLI overrides
        if let model = model {
            config.llm.model = model
        }

        if let provider = provider {
            config.llm.provider = provider
        }

        if let endpoint = endpoint {
            config.llm.endpoint = endpoint
        }

        if noColor {
            config.ui.color = false
        }

        if noSandbox {
            config.safety.sandboxEnabled = false
        }

        if noReadline {
            config.ui.enableReadline = false
        }

        if showTokens {
            config.ui.showTokenUsage = true
        }

        if showTools {
            config.ui.showToolCalls = true
        }

        // Create logger with color setting
        let logger = Logger(component: "test7", useColor: config.ui.color)

        if dryRun {
            logger.info("DRY RUN MODE: No tools will be executed")
            logger.info("Configuration:")
            print("  Provider: \(config.llm.provider)")
            print("  Model: \(config.llm.model)")
            print("  Endpoint: \(config.llm.endpoint)")
            return
        }

        // Validate API key
        guard config.llm.apiKey != nil else {
            logger.error("No API key configured. Set ANTHROPIC_API_KEY environment variable or add to config.")
            throw ExitCode.failure
        }

        // Print configuration summary
        logger.info("test7 Starting")
        if let logPath = Logger.getLogFilePath() {
            logger.info("Log file: \(logPath)")
        }
        logger.debug("Provider: \(config.llm.provider)")
        logger.debug("Model: \(config.llm.model)")
        logger.debug("Endpoint: \(config.llm.endpoint)")
        logger.debug("Sandbox: \(config.safety.sandboxEnabled ? "enabled" : "disabled")")

        // Start agent loop
        let agent = AgentLoop(config: config, logger: logger)
        Task {
            await agent.run()
        }

        // Wait for agent to finish
        RunLoop.main.run()
    }
}
