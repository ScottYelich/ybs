// Implements: Step 35 (Runtime Provider Switching) + ybs-spec.md § 7 (LLM Provider Abstraction)
import Foundation

/// Factory for creating LLM clients based on provider
class LLMClientFactory {
    /// Create appropriate LLM client for the given config
    static func createClient(config: LLMConfig, logger: Logger) -> LLMClientProtocol {
        let provider = config.provider.lowercased()

        switch provider {
        case "anthropic":
            logger.info("Creating Anthropic LLM client")
            return AnthropicLLMClient(config: config, logger: logger)

        case "apple":
            logger.info("Creating Apple ML client")
            return AppleLLMClient(config: config, logger: logger)

        case "ollama", "openai", "openai-compatible":
            logger.info("Creating OpenAI-compatible LLM client")
            return LLMClient(config: config, logger: logger)

        default:
            logger.warn("Unknown provider '\(config.provider)', using generic OpenAI-compatible client")
            return LLMClient(config: config, logger: logger)
        }
    }
}
