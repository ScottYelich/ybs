// Implements: ybs-spec.md § 2.4 (Interactive Input - Readline)
import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Protocol for handling user input
protocol InputHandler {
    /// Read a line of input with optional prompt
    /// - Parameter prompt: Optional prompt to display
    /// - Returns: Input string, or nil on EOF
    func readLine(prompt: String) -> String?

    /// Clean up resources (close history file, etc.)
    func cleanup()
}

/// Plain input handler using Swift's readLine() - no history or editing
class PlainInputHandler: InputHandler {
    func readLine(prompt: String) -> String? {
        print(prompt, terminator: "")
        fflush(stdout)
        return Swift.readLine()
    }

    func cleanup() {
        // Nothing to clean up
    }
}

#if canImport(LineNoise)
import LineNoise

/// Readline input handler using LineNoise - with history and editing
class ReadlineInputHandler: InputHandler {
    private let lineNoise: LineNoise
    private let historyFile: String
    private let maxEntries: Int
    private let logger: Logger
    private var historyEntries: [String] = []  // Track our own history for persistence

    init(historyFile: String, maxEntries: Int, logger: Logger) {
        self.lineNoise = LineNoise()
        self.historyFile = NSString(string: historyFile).expandingTildeInPath
        self.maxEntries = maxEntries
        self.logger = logger

        // Load history
        loadHistory()

        // Configure LineNoise
        lineNoise.setHistoryMaxLength(UInt(maxEntries))

        logger.debug("ReadlineInputHandler initialized with TERM=\(ProcessInfo.processInfo.environment["TERM"] ?? "unset")")
    }

    func readLine(prompt: String) -> String? {
        do {
            let input = try lineNoise.getLine(prompt: prompt)

            // Don't save empty lines
            guard !input.trimmingCharacters(in: .whitespaces).isEmpty else {
                return input
            }

            // Don't save lines starting with space (privacy feature)
            guard !input.hasPrefix(" ") else {
                return input
            }

            // Add to LineNoise history
            lineNoise.addHistory(input)

            // Add to our own history array for persistence
            historyEntries.append(input)

            // Trim to max entries
            if historyEntries.count > maxEntries {
                historyEntries = Array(historyEntries.suffix(maxEntries))
            }

            // Save to file
            saveHistory()

            return input
        } catch LinenoiseError.EOF {
            return nil
        } catch {
            logger.error("Readline error: \(error)")
            return nil
        }
    }

    func cleanup() {
        saveHistory()
    }

    // MARK: - History Management

    private func loadHistory() {
        let url = URL(fileURLWithPath: historyFile)

        guard FileManager.default.fileExists(atPath: historyFile) else {
            logger.debug("History file not found, starting fresh: \(historyFile)")
            return
        }

        do {
            let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
            let lines = contents.components(separatedBy: .newlines)

            // Load up to maxEntries most recent lines
            let recentLines = Array(lines.suffix(maxEntries))

            for line in recentLines where !line.isEmpty {
                lineNoise.addHistory(line)
                historyEntries.append(line)
            }

            logger.debug("Loaded \(recentLines.count) history entries from \(historyFile)")
        } catch {
            logger.warn("Failed to load history: \(error)")
        }
    }

    private func saveHistory() {
        let url = URL(fileURLWithPath: historyFile)

        // Ensure directory exists
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            // Keep only most recent maxEntries
            let recentHistory = Array(historyEntries.suffix(maxEntries))

            // Write to file
            let contents = recentHistory.joined(separator: "\n")
            try contents.write(to: url, atomically: true, encoding: String.Encoding.utf8)

            // Set restrictive permissions (600)
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: historyFile
            )
        } catch {
            logger.warn("Failed to save history: \(error)")
        }
    }
}
#endif
