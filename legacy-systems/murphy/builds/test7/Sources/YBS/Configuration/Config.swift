// Implements: Step 5 (Configuration Schema) + ybs-spec.md § 2.3 (Configuration Schema)
import Foundation

// Main configuration structure
struct YBSConfig: Codable {
    var version: String
    var llm: LLMConfig
    var context: ContextConfig
    var agent: AgentConfig
    var safety: SafetyConfig
    var tools: ToolsConfig
    var git: GitConfig
    var ui: UIConfig

    init() {
        self.version = "1.0"
        self.llm = LLMConfig()
        self.context = ContextConfig()
        self.agent = AgentConfig()
        self.safety = SafetyConfig()
        self.tools = ToolsConfig()
        self.git = GitConfig()
        self.ui = UIConfig()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        self.llm = try container.decodeIfPresent(LLMConfig.self, forKey: .llm) ?? LLMConfig()
        self.context = try container.decodeIfPresent(ContextConfig.self, forKey: .context) ?? ContextConfig()
        self.agent = try container.decodeIfPresent(AgentConfig.self, forKey: .agent) ?? AgentConfig()
        self.safety = try container.decodeIfPresent(SafetyConfig.self, forKey: .safety) ?? SafetyConfig()
        self.tools = try container.decodeIfPresent(ToolsConfig.self, forKey: .tools) ?? ToolsConfig()
        self.git = try container.decodeIfPresent(GitConfig.self, forKey: .git) ?? GitConfig()
        self.ui = try container.decodeIfPresent(UIConfig.self, forKey: .ui) ?? UIConfig()
    }
}

// LLM configuration
struct LLMConfig: Codable {
    var provider: String
    var model: String
    var endpoint: String
    var apiKey: String?
    var temperature: Double
    var maxTokens: Int
    var timeoutSeconds: Int

    enum CodingKeys: String, CodingKey {
        case provider, model, endpoint
        case apiKey = "api_key"
        case temperature
        case maxTokens = "max_tokens"
        case timeoutSeconds = "timeout_seconds"
    }

    init() {
        self.provider = "ollama"
        self.model = "qwen3:14b"
        self.endpoint = "http://localhost:11434"
        self.apiKey = nil
        self.temperature = 0.7
        self.maxTokens = 4096
        self.timeoutSeconds = 120
    }

    init(
        provider: String,
        model: String,
        endpoint: String,
        api_key: String? = nil,
        max_tokens: Int? = nil,
        temperature: Double? = nil
    ) {
        self.provider = provider
        self.model = model
        self.endpoint = endpoint
        self.apiKey = api_key
        self.temperature = temperature ?? 0.7
        self.maxTokens = max_tokens ?? 4096
        self.timeoutSeconds = 120
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.provider = try container.decodeIfPresent(String.self, forKey: .provider) ?? "ollama"
        self.model = try container.decodeIfPresent(String.self, forKey: .model) ?? "qwen3:14b"
        self.endpoint = try container.decodeIfPresent(String.self, forKey: .endpoint) ?? "http://localhost:11434"
        self.apiKey = try container.decodeIfPresent(String.self, forKey: .apiKey)
        self.temperature = try container.decodeIfPresent(Double.self, forKey: .temperature) ?? 0.7
        self.maxTokens = try container.decodeIfPresent(Int.self, forKey: .maxTokens) ?? 4096
        self.timeoutSeconds = try container.decodeIfPresent(Int.self, forKey: .timeoutSeconds) ?? 120
    }
}

// Context configuration
struct ContextConfig: Codable {
    var maxMessages: Int = 50
    var maxTokens: Int = 32000
    var compactionThreshold: Double = 0.95
    var repoMapTokens: Int = 1024
    var maxToolOutputChars: Int = 10000

    enum CodingKeys: String, CodingKey {
        case maxMessages = "max_messages"
        case maxTokens = "max_tokens"
        case compactionThreshold = "compaction_threshold"
        case repoMapTokens = "repo_map_tokens"
        case maxToolOutputChars = "max_tool_output_chars"
    }
}

// Agent configuration
struct AgentConfig: Codable {
    var maxIterations: Int = 25
    var retryAttempts: Int = 3
    var retryBackoffBaseMs: Int = 1000

    enum CodingKeys: String, CodingKey {
        case maxIterations = "max_iterations"
        case retryAttempts = "retry_attempts"
        case retryBackoffBaseMs = "retry_backoff_base_ms"
    }
}

// Safety configuration
struct SafetyConfig: Codable {
    var sandboxEnabled: Bool = true
    var sandboxAllowedPaths: [String] = ["./"]
    var sandboxBlockedPaths: [String] = ["~/.ssh", "~/.aws", "~/.config"]
    var requireConfirmation: [String] = ["write_file", "run_shell", "delete_file"]
    var blockedCommands: [String] = ["rm -rf /", "sudo", "chmod 777"]
    var shellTimeoutSeconds: Int = 60

    enum CodingKeys: String, CodingKey {
        case sandboxEnabled = "sandbox_enabled"
        case sandboxAllowedPaths = "sandbox_allowed_paths"
        case sandboxBlockedPaths = "sandbox_blocked_paths"
        case requireConfirmation = "require_confirmation"
        case blockedCommands = "blocked_commands"
        case shellTimeoutSeconds = "shell_timeout_seconds"
    }
}

// Tools configuration
struct ToolsConfig: Codable {
    var builtin: [String: BuiltinToolConfig] = [:]
    var external: [ExternalToolConfig] = []
    var searchPaths: [String] = ["~/.config/ybs/tools", "~/.ybs/tools", "./tools"]

    enum CodingKeys: String, CodingKey {
        case builtin, external
        case searchPaths = "search_paths"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.builtin = try container.decodeIfPresent([String: BuiltinToolConfig].self, forKey: .builtin) ?? [:]
        self.external = try container.decodeIfPresent([ExternalToolConfig].self, forKey: .external) ?? []
        self.searchPaths = try container.decodeIfPresent([String].self, forKey: .searchPaths) ?? ["~/.config/ybs/tools", "~/.ybs/tools", "./tools"]
    }
}

struct BuiltinToolConfig: Codable {
    var enabled: Bool = true
    var timeoutSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case enabled
        case timeoutSeconds = "timeout_seconds"
    }
}

struct ExternalToolConfig: Codable {
    var name: String
    var type: String
    var path: String
    var enabled: Bool = true
}

// Git configuration
struct GitConfig: Codable {
    var autoCommit: Bool = true
    var commitMessagePrefix: String = "[ybs]"

    enum CodingKeys: String, CodingKey {
        case autoCommit = "auto_commit"
        case commitMessagePrefix = "commit_message_prefix"
    }
}

// UI configuration
struct UIConfig: Codable {
    var color: Bool = true
    var showTokenUsage: Bool = true
    var showToolCalls: Bool = true
    var streamResponses: Bool = true
    var consoleLogLevel: String = "none"  // none, info, debug, warn, error
    var enableReadline: Bool = false  // Disabled by default - enable explicitly if needed
    var historyFile: String = "~/.config/ybs/history"
    var historyMaxEntries: Int = 1000

    enum CodingKeys: String, CodingKey {
        case color
        case showTokenUsage = "show_token_usage"
        case showToolCalls = "show_tool_calls"
        case streamResponses = "stream_responses"
        case consoleLogLevel = "console_log_level"
        case enableReadline = "enable_readline"
        case historyFile = "history_file"
        case historyMaxEntries = "history_max_entries"
    }
}
