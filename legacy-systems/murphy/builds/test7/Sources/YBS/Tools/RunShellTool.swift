// Implements: Step 20 (run_shell Tool) + ybs-spec.md § 3.6 (run_shell)
import Foundation

struct RunShellTool: ToolProtocol {
    let name = "run_shell"
    let description = """
    Execute a shell command and return the output. Use this for running build commands, \
    tests, git operations, package managers, etc.
    """

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "command": ToolProperty(
                    type: "string",
                    description: "Shell command to execute"
                ),
                "working_dir": ToolProperty(
                    type: "string",
                    description: "Working directory for command (default: current directory)"
                ),
                "timeout": ToolProperty(
                    type: "integer",
                    description: "Timeout in seconds (default: 60)"
                )
            ],
            required: ["command"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var command: String
            var working_dir: String?
            var timeout: Int?
        }

        let data = arguments.data(using: .utf8)!
        let args: Args
        do {
            args = try JSONDecoder().decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        let timeout = args.timeout ?? 60
        let workingDir = args.working_dir.map { NSString(string: $0).expandingTildeInPath }

        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", args.command]

        if let workingDir = workingDir {
            process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        }

        // Setup pipes
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Capture output
        var stdoutData = Data()
        var stderrData = Data()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            stdoutData.append(handle.availableData)
        }

        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            stderrData.append(handle.availableData)
        }

        // Start process
        do {
            try process.run()
        } catch {
            return .failure("Failed to start process: \(error.localizedDescription)")
        }

        // Wait with timeout
        let startTime = Date()
        while process.isRunning {
            if Date().timeIntervalSince(startTime) > Double(timeout) {
                process.terminate()
                return .failure("Command timed out after \(timeout) seconds")
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }

        // Close pipes
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        // Get final output
        stdoutData.append(try! stdoutPipe.fileHandleForReading.readToEnd() ?? Data())
        stderrData.append(try! stderrPipe.fileHandleForReading.readToEnd() ?? Data())

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let exitCode = Int(process.terminationStatus)

        // Format result
        var output = ""

        if !stdout.isEmpty {
            output += "STDOUT:\n\(stdout)\n"
        }

        if !stderr.isEmpty {
            output += "STDERR:\n\(stderr)\n"
        }

        output += "Exit code: \(exitCode)"

        if exitCode == 0 {
            return .success(output)
        } else {
            return .failure(output)
        }
    }
}
