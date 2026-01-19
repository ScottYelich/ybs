#!/usr/bin/env swift

import Foundation

// Include the configuration code directly for testing
#sourceLocation(file: "Sources/test7/Configuration/Config.swift", line: 1)

// Main configuration structure
struct YBSConfig: Codable {
    var version: String = "1.0"
    var llm: LLMConfig = LLMConfig()
    var context: ContextConfig = ContextConfig()
    var agent: AgentConfig = AgentConfig()
    var safety: SafetyConfig = SafetyConfig()
    var tools: ToolsConfig = ToolsConfig()
    var git: GitConfig = GitConfig()
    var ui: UIConfig = UIConfig()
}

// LLM configuration
struct LLMConfig: Codable {
    var provider: String = "ollama"
    var model: String = "qwen3:14b"
    var endpoint: String = "http://localhost:11434"
    var apiKey: String? = nil
    var temperature: Double = 0.7
    var maxTokens: Int = 4096
    var timeoutSeconds: Int = 120

    enum CodingKeys: String, CodingKey {
        case provider, model, endpoint
        case apiKey = "api_key"
        case temperature
        case maxTokens = "max_tokens"
        case timeoutSeconds = "timeout_seconds"
    }
}

// Context configuration
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

    enum CodingKeys: String, CodingKey {
        case sandboxEnabled = "sandbox_enabled"
        case sandboxAllowedPaths = "sandbox_allowed_paths"
        case sandboxBlockedPaths = "sandbox_blocked_blocked_paths"
        case requireConfirmation = "require_confirmation"
        case blockedCommands = "blocked_commands"
    }
}

// Tools configuration
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

    enum CodingKeys: String, CodingKey {
        case color
        case showTokenUsage = "show_token_usage"
        case showToolCalls = "show_tool_calls"
        case streamResponses = "stream_responses"
    }
}

#sourceLocation()

// Test 1: Default configuration
print("Test 1: Default Configuration")
let config = YBSConfig()
assert(config.version == "1.0", "Version should be 1.0")
assert(config.llm.provider == "ollama", "Provider should be ollama")
assert(config.llm.model == "qwen3:14b", "Model should be qwen3:14b")
assert(config.context.maxTokens == 32000, "Max tokens should be 32000")
assert(config.safety.sandboxEnabled == true, "Sandbox should be enabled")
print("✓ Default configuration test passed")

// Test 2: JSON Encoding
print("\nTest 2: JSON Encoding")
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let data = try! encoder.encode(config)
let jsonString = String(data: data, encoding: .utf8)!
assert(jsonString.contains("\"provider\""), "JSON should contain provider field")
print("✓ JSON encoding test passed")

// Test 3: JSON Decoding
print("\nTest 3: JSON Decoding")
let testJSON = """
{
    "version": "1.0",
    "llm": {
        "provider": "anthropic",
        "model": "claude-3-sonnet",
        "endpoint": "https://api.anthropic.com",
        "temperature": 0.8
    }
}
"""
let decoder = JSONDecoder()
let decodedConfig = try! decoder.decode(YBSConfig.self, from: testJSON.data(using: .utf8)!)
assert(decodedConfig.llm.provider == "anthropic", "Provider should be anthropic")
assert(decodedConfig.llm.model == "claude-3-sonnet", "Model should be claude-3-sonnet")
assert(decodedConfig.llm.temperature == 0.8, "Temperature should be 0.8")
print("✓ JSON decoding test passed")

print("\n✓ All configuration tests passed successfully!")
