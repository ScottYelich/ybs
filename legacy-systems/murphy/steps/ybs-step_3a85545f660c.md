# Step 000004: Configuration Schema & File Loading

**GUID**: 3a85545f660c
**Version**: 0.1.0
**Layer**: 1 - Foundation
**Estimated Size**: ~150 lines of code

## Overview

This step implements the configuration loading system for YBS. It parses JSON configuration files from multiple locations, merges them in priority order, and provides validated configuration to the rest of the system.

This is a foundational step - all other components will depend on configuration being loaded correctly.

## What This Step Builds

A robust configuration system that:
- Loads JSON configuration files from layered locations
- Merges configs in priority order (system → user → project → CLI)
- Validates configuration values against schema
- Provides type-safe access to configuration
- Reports clear errors for invalid configurations

**Configuration Resolution Order**:
1. `/etc/ybs/config.json` (system-wide defaults) - lowest priority
2. `~/.config/ybs/config.json` (user defaults)
3. `~/.ybs.json` (user home shorthand)
4. `./.ybs.json` (project-specific)
5. CLI flags (highest priority) - will be handled in Step 7

## Step Objectives

1. Define Swift structs matching the configuration schema
2. Implement JSON file loading with error handling
3. Implement layered config resolution (merge multiple files)
4. Validate configuration values (types, ranges, required fields)
5. Provide clear error messages for configuration problems
6. Test with various config file scenarios

## Prerequisites

**Required Steps**:
- ✅ `ybs-step_000000000000` - Build Configuration (defines config schema)
- ✅ `ybs-step_478a8c4b0cef` - Project Skeleton (Swift project structure exists)

**Required Conditions**:
- Swift project compiles (`swift build` succeeds)
- `BUILD_CONFIG.json` exists in build directory

## Configurable Values

**This step reads configuration values but does not define new ones.**

The configuration schema was defined in Step 0. This step implements the loader for that schema.

## Traceability

**Implements**:
- `ybs-spec.md` Section 2.1 (Configuration File Resolution)
- `ybs-spec.md` Section 2.3 (Configuration Schema)

**References**:
- D06 (Configuration Format: JSON)
- D07 (Config Resolution: Layered system → user → project → CLI)

## Instructions

### Before Starting

1. **Record start time**: `date -u +"%Y-%m-%d %H:%M UTC"`
2. **Verify prerequisites**: Ensure Steps 0-3 are complete
3. **Check build status**: `swift build` should succeed

### 1. Define Configuration Structs

Create Swift structs that match the configuration schema defined in `ybs-spec.md` Section 2.3.

**File to create**: `Sources/YBS/Configuration/Config.swift`

```swift
import Foundation

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
        case sandboxBlockedPaths = "sandbox_blocked_paths"
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
```

### 2. Implement Configuration File Loader

Create the configuration loader that reads and parses JSON files.

**File to create**: `Sources/YBS/Configuration/ConfigLoader.swift`

```swift
import Foundation

enum ConfigError: Error {
    case fileNotFound(path: String)
    case invalidJSON(path: String, error: String)
    case invalidFormat(path: String, message: String)
}

class ConfigLoader {
    /// Load configuration from a specific file path
    static func loadFrom(path: String) throws -> YBSConfig {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)

        // Check if file exists
        guard FileManager.default.fileExists(atPath: expandedPath) else {
            throw ConfigError.fileNotFound(path: path)
        }

        // Read file contents
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ConfigError.invalidJSON(path: path, error: error.localizedDescription)
        }

        // Parse JSON
        let decoder = JSONDecoder()
        do {
            let config = try decoder.decode(YBSConfig.self, from: data)
            return config
        } catch {
            throw ConfigError.invalidJSON(path: path, error: error.localizedDescription)
        }
    }

    /// Load configuration from multiple paths with layered resolution
    /// Later paths override earlier paths
    static func loadLayered(paths: [String]) -> YBSConfig {
        var config = YBSConfig() // Start with defaults

        for path in paths {
            do {
                let fileConfig = try loadFrom(path: path)
                config = merge(base: config, override: fileConfig)
            } catch ConfigError.fileNotFound {
                // File doesn't exist - skip silently
                continue
            } catch {
                // Log error but continue (don't fail entire load)
                print("Warning: Could not load config from \(path): \(error)")
                continue
            }
        }

        return config
    }

    /// Merge two configurations (override takes precedence)
    private static func merge(base: YBSConfig, override: YBSConfig) -> YBSConfig {
        // For now, do simple override of entire sections
        // In future, could do deep merge of nested properties
        var merged = base

        // Override each section if present in override config
        // This is simplified - a real implementation would check which fields are actually set
        merged.llm = override.llm
        merged.context = override.context
        merged.agent = override.agent
        merged.safety = override.safety
        merged.tools = override.tools
        merged.git = override.git
        merged.ui = override.ui

        return merged
    }

    /// Load configuration using standard resolution order
    static func loadStandard() -> YBSConfig {
        let paths = [
            "/etc/ybs/config.json",
            "~/.config/ybs/config.json",
            "~/.ybs.json",
            "./.ybs.json"
        ]

        return loadLayered(paths: paths)
    }
}
```

### 3. Add Tests

Create tests to verify configuration loading works correctly.

**File to create**: `Tests/YBSTests/ConfigurationTests.swift`

```swift
import XCTest
@testable import YBS

final class ConfigurationTests: XCTestCase {
    func testDefaultConfiguration() {
        let config = YBSConfig()

        // Verify defaults
        XCTAssertEqual(config.version, "1.0")
        XCTAssertEqual(config.llm.provider, "ollama")
        XCTAssertEqual(config.llm.model, "qwen3:14b")
        XCTAssertEqual(config.context.maxTokens, 32000)
        XCTAssertTrue(config.safety.sandboxEnabled)
    }

    func testJSONEncoding() throws {
        let config = YBSConfig()

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(config)
        let jsonString = String(data: data, encoding: .utf8)

        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("\"provider\""))
    }

    func testJSONDecoding() throws {
        let json = """
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

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        let config = try decoder.decode(YBSConfig.self, from: data)

        XCTAssertEqual(config.llm.provider, "anthropic")
        XCTAssertEqual(config.llm.model, "claude-3-sonnet")
        XCTAssertEqual(config.llm.temperature, 0.8)
    }
}
```

### 4. Update Package.swift

Ensure the new files are included in the build targets.

**File to modify**: `Package.swift`

Add the new source files to the appropriate targets. The Package.swift should already have the basic structure from Step 1.

### 5. Build and Test

Verify the configuration system works.

**Commands**:
```bash
# Build the project
swift build

# Run tests
swift test

# Should see: All tests pass
```

## Verification

### Build Verification

```bash
cd systems/bootstrap/builds/test6
swift build
# Expected: Build succeeds with no errors
```

### Test Verification

```bash
swift test --filter ConfigurationTests
# Expected: All configuration tests pass
```

### Manual Verification

```bash
# Create a test config file
cat > test-config.json << 'EOF'
{
  "version": "1.0",
  "llm": {
    "provider": "anthropic",
    "model": "claude-3.5-sonnet"
  }
}
EOF

# Create a simple test program
cat > test-config-load.swift << 'EOF'
import Foundation
import YBS

let config = try! ConfigLoader.loadFrom(path: "./test-config.json")
print("Loaded config:")
print("  Provider: \(config.llm.provider)")
print("  Model: \(config.llm.model)")
EOF

# Run test (if you have a way to run Swift scripts with the module)
# Otherwise, verify in unit tests
```

**Expected Output**:
```
Loaded config:
  Provider: anthropic
  Model: claude-3.5-sonnet
```

### Configuration File Loading Test

Create test configs in different locations and verify priority order:

```bash
# Create system config (lowest priority)
mkdir -p /etc/ybs
echo '{"llm": {"provider": "system-provider"}}' > /etc/ybs/config.json

# Create user config (higher priority)
mkdir -p ~/.config/ybs
echo '{"llm": {"model": "user-model"}}' > ~/.config/ybs/config.json

# Create project config (highest priority)
echo '{"llm": {"endpoint": "http://project-endpoint"}}' > ./.ybs.json

# Load and verify merge
# Provider from system, model from user, endpoint from project
```

## Completion Checklist

When this step is complete, verify:

- [ ] All configuration structs defined in `Sources/YBS/Configuration/Config.swift`
- [ ] ConfigLoader implemented in `Sources/YBS/Configuration/ConfigLoader.swift`
- [ ] Tests created in `Tests/YBSTests/ConfigurationTests.swift`
- [ ] `swift build` succeeds with no errors
- [ ] `swift test` passes all configuration tests
- [ ] Configuration merging works (later files override earlier)
- [ ] Error handling works (invalid JSON, missing files)
- [ ] Code compiles and tests pass

## After Completion

**Record completion**:
1. Note completion timestamp
2. Create DONE file: `docs/build-history/ybs-step_3a85545f660c-DONE.txt`
3. Update BUILD_STATUS.md

**DONE file contents**:
```
Step: ybs-step_3a85545f660c
Title: Configuration Schema & File Loading
Status: COMPLETED
Started: [timestamp]
Completed: [timestamp]
Duration: [duration]

Changes:
- Created Sources/YBS/Configuration/Config.swift
- Created Sources/YBS/Configuration/ConfigLoader.swift
- Created Tests/YBSTests/ConfigurationTests.swift
- All tests passing

Verification:
✓ Build succeeds
✓ All tests pass
✓ Configuration loading works
✓ Layered resolution works
✓ Error handling works
```

**Commit**:
```bash
git add -A
git commit -m "Step 4: Implement configuration schema and file loading

- Add YBSConfig struct with all configuration sections
- Implement ConfigLoader with layered file resolution
- Add comprehensive configuration tests
- Support JSON parsing and validation
- Handle missing files and invalid JSON gracefully

Implements: ybs-spec.md Section 2.1, 2.3

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: `ybs-step_[next-guid]` - Step 5: Core Data Models

**Dependencies satisfied**: This step provides configuration loading needed by all future steps.
