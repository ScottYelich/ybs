#!/usr/bin/env swift

import Foundation

// Inline the configuration structs for verification
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

struct ContextConfig: Codable {
    var maxTokens: Int = 32000
    var compactionThreshold: Double = 0.95
    var repoMapTokens: Int = 1024
    var maxToolOutputChars: Int = 10000

    enum CodingKeys: String, CodingKey {
        case maxTokens = "max_tokens"
        case compactionThreshold = "compaction_threshold"
        case repoMapTokens = "repo_map_tokens"
        case maxToolOutputChars = "max_tool_output_chars"
    }
}

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

struct SafetyConfig: Codable {
    var sandboxEnabled: Bool = true
    var sandboxAllowedPaths: [String] = ["./"]
    var sandboxBlockedPaths: [String] = ["~/.ssh", "~/.aws", "~/.config"]
    var requireConfirmation: [String] = ["write_file", "run_shell", "delete_file"]
    var blockedCommands: [String] = ["rm -rf /", "sudo", "chmod 777"]

    enum CodingKeys: String, CodingKey {
        case sandboxEnabled = "sandbox_enabled"
        case sandboxAllowedPaths = "sandbox_allowed_paths"
        case sandboxBlockedPaths = "sandbox_blocked_paths"
        case requireConfirmation = "require_confirmation"
        case blockedCommands = "blocked_commands"
    }
}

struct ToolsConfig: Codable {
    var builtin: [String: BuiltinToolConfig] = [:]
    var external: [ExternalToolConfig] = []
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

struct GitConfig: Codable {
    var autoCommit: Bool = true
    var commitMessagePrefix: String = "[ybs]"

    enum CodingKeys: String, CodingKey {
        case autoCommit = "auto_commit"
        case commitMessagePrefix = "commit_message_prefix"
    }
}

struct UIConfig: Codable {
    var color: Bool = true
    var showTokenUsage: Bool = true
    var showToolCalls: Bool = true
    var streamResponses: Bool = true

    enum CodingKeys: String, CodingKey {
        case color
        case showTokenUsage = "show_token_usage"
        case showToolCalls = "show_tool_calls"
        case streamResponses = "stream_responses"
    }
}

// Verification tests
print("Configuration Verification")
print("===========================\n")

var passCount = 0
var failCount = 0

func verify(_ name: String, _ condition: Bool) {
    if condition {
        print("✓ \(name)")
        passCount += 1
    } else {
        print("✗ \(name)")
        failCount += 1
    }
}

// Test 1: Default configuration
print("Test 1: Default configuration values")
let config = YBSConfig()
verify("Version is 1.0", config.version == "1.0")
verify("LLM provider is ollama", config.llm.provider == "ollama")
verify("LLM model is qwen3:14b", config.llm.model == "qwen3:14b")
verify("Context max tokens is 32000", config.context.maxTokens == 32000)
verify("Sandbox is enabled", config.safety.sandboxEnabled == true)
print("")

// Test 2: JSON encoding
print("Test 2: JSON encoding")
do {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(config)
    let jsonString = String(data: data, encoding: .utf8)
    verify("JSON encoding produces output", jsonString != nil)
    verify("JSON contains provider field", jsonString?.contains("\"provider\"") ?? false)
    print("")
} catch {
    print("✗ JSON encoding failed: \(error)")
    failCount += 2
    print("")
}

// Test 3: JSON decoding
print("Test 3: JSON decoding")
do {
    let json = """
    {
        "version": "1.0",
        "llm": {
            "provider": "anthropic",
            "model": "claude-3-sonnet",
            "endpoint": "https://api.anthropic.com",
            "temperature": 0.8,
            "max_tokens": 4096,
            "timeout_seconds": 120
        }
    }
    """

    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let decodedConfig = try decoder.decode(YBSConfig.self, from: data)

    verify("Decoded provider is anthropic", decodedConfig.llm.provider == "anthropic")
    verify("Decoded model is claude-3-sonnet", decodedConfig.llm.model == "claude-3-sonnet")
    verify("Decoded temperature is 0.8", decodedConfig.llm.temperature == 0.8)
    print("")
} catch {
    print("✗ JSON decoding failed: \(error)")
    failCount += 3
    print("")
}

// Summary
print("===========================")
print("Results: \(passCount) passed, \(failCount) failed")
if failCount == 0 {
    print("✓ All tests passed!")
    exit(0)
} else {
    print("✗ Some tests failed")
    exit(1)
}
