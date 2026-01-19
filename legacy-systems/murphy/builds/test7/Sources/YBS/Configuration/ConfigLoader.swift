// Implements: Step 5 (Configuration Schema) + ybs-spec.md § 2.1 (Config File Resolution)
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
