// Implements: Step 37 (Shell Injection) + ybs-spec.md § 6.6 (Shell Injection Commands)
import Foundation

/// Handles shell injection commands that start with !
class ShellInjectionHandler {
    private let toolExecutor: ToolExecutor
    private let logger: Logger
    private let maxOutputLength: Int

    init(toolExecutor: ToolExecutor, logger: Logger, maxOutputLength: Int = 10000) {
        self.toolExecutor = toolExecutor
        self.logger = logger
        self.maxOutputLength = maxOutputLength
    }

    /// Check if input is a shell injection command
    func isShellCommand(_ input: String) -> Bool {
        return input.hasPrefix("!")
    }

    /// Execute shell command and return formatted output for context injection
    /// Returns tuple: (shouldInject: Bool, message: String)
    func handleShellCommand(_ input: String) async -> (Bool, String) {
        // Extract command (everything after '!')
        let command = String(input.dropFirst()).trimmingCharacters(in: .whitespaces)

        guard !command.isEmpty else {
            print("\n❌ Error: No command specified")
            print("Usage: !<command>")
            print("Example: !ls -la\n")
            return (false, "")
        }

        // Show what we're running
        print("\n💻 Running: \(command)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        do {
            // Execute via run_shell tool (respects sandbox)
            // Get current working directory
            let cwd = FileManager.default.currentDirectoryPath
            let arguments = [
                "command": command,
                "working_dir": cwd
            ]
            let encoder = JSONEncoder()
            let argumentsData = try encoder.encode(arguments)
            let argumentsString = String(data: argumentsData, encoding: .utf8) ?? "{}"

            let result = try await toolExecutor.execute(
                toolName: "run_shell",
                arguments: argumentsString
            )

            // Parse result
            var stdout = ""
            var stderr = ""
            var exitCode = 0

            if result.success, let output = result.output {
                // Try to parse JSON output from run_shell tool
                if let data = output.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    stdout = json["stdout"] as? String ?? ""
                    stderr = json["stderr"] as? String ?? ""
                    if let exitCodeStr = json["exit_code"] as? String {
                        exitCode = Int(exitCodeStr) ?? 0
                    } else if let exitCodeInt = json["exit_code"] as? Int {
                        exitCode = exitCodeInt
                    }
                } else {
                    // Fallback: treat entire output as stdout
                    stdout = output
                }
            } else if let error = result.error {
                // Command failed
                stderr = error
                exitCode = 1
            }

            // Display output to user
            if !stdout.isEmpty {
                print(stdout)
            }
            if !stderr.isEmpty {
                print("stderr: \(stderr)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("Exit code: \(exitCode)\n")

            // Truncate if too long
            let truncatedStdout = truncateOutput(stdout)
            let truncatedStderr = truncateOutput(stderr)

            // Format message for LLM context
            let contextMessage = formatContextMessage(
                command: command,
                stdout: truncatedStdout,
                stderr: truncatedStderr,
                exitCode: exitCode,
                wasTruncated: truncatedStdout.count < stdout.count || truncatedStderr.count < stderr.count
            )

            logger.info("Shell injection: \(command) (exit: \(exitCode))")
            return (true, contextMessage)

        } catch {
            // Execution error
            print("❌ Error executing command: \(error)\n")
            logger.error("Shell injection failed: \(error)")

            let errorMessage = """
            [Shell command failed]
            Command: \(command)
            Error: \(error.localizedDescription)
            """

            return (true, errorMessage)
        }
    }

    // MARK: - Helper Methods

    /// Truncate output if too long
    private func truncateOutput(_ output: String) -> String {
        if output.count <= maxOutputLength {
            return output
        }

        let truncated = String(output.prefix(maxOutputLength))
        return truncated + "\n\n... (output truncated, \(output.count) total characters)"
    }

    /// Format context message for LLM
    private func formatContextMessage(
        command: String,
        stdout: String,
        stderr: String,
        exitCode: Int,
        wasTruncated: Bool
    ) -> String {
        var message = """
        [Shell command output]
        Command: \(command)
        Exit code: \(exitCode)
        """

        if !stdout.isEmpty {
            message += "\n\nOutput:\n\(stdout)"
        }

        if !stderr.isEmpty {
            message += "\n\nStderr:\n\(stderr)"
        }

        if stdout.isEmpty && stderr.isEmpty {
            message += "\n\n(No output)"
        }

        if wasTruncated {
            message += "\n\nNote: Output was truncated due to length."
        }

        return message
    }
}
