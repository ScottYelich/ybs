// Implements: Step 35 (Runtime Provider Switching) + ybs-spec.md § 7 (LLM Provider Abstraction)
import Foundation

/// Default configuration values for LLM providers
struct ProviderDefaults {
    /// Get default endpoint for a provider
    static func endpoint(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "http://localhost:11434/api/chat"
        case "openai":
            return "https://api.openai.com/v1/chat/completions"
        case "anthropic":
            return "https://api.anthropic.com/v1/messages"
        case "apple":
            return ""  // Not used - native framework
        default:
            return ""  // User must specify
        }
    }

    /// Get default model for a provider
    static func model(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "qwen2.5:14b"
        case "openai":
            return "gpt-4o-mini"
        case "anthropic":
            return "claude-3-5-sonnet-20241022"
        case "apple":
            return "foundation"
        default:
            return ""  // User must specify
        }
    }

    /// Get list of supported providers
    static let supportedProviders = [
        "ollama",
        "openai",
        "anthropic",
        "apple"
    ]

    /// Get provider display info
    static func info(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "Ollama (local, free) - Default: qwen2.5:14b"
        case "openai":
            return "OpenAI (cloud, API key required) - Default: gpt-4o-mini"
        case "anthropic":
            return "Anthropic (cloud, API key required) - Default: claude-3-5-sonnet-20241022"
        case "apple":
            return "Apple Foundation Model (local, macOS 15+, free)"
        default:
            return "Unknown provider"
        }
    }

    /// Check if provider requires API key
    static func requiresAPIKey(_ provider: String) -> Bool {
        switch provider.lowercased() {
        case "openai", "anthropic":
            return true
        case "ollama", "apple":
            return false
        default:
            return false
        }
    }
}
