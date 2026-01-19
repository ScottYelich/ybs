// Implements: Step 24 (External Tool Protocol) + ybs-spec.md § 4 (External Tools)
import Foundation

/// External tool that executes external binaries via JSON protocol
struct ExternalTool: ToolProtocol {
    let name: String
    let description: String
    let executablePath: String
    let schema: ExternalToolSchema
    let timeout: TimeInterval

    var parameters: ToolParameters {
        // Convert external schema to ToolParameters format
        var properties: [String: ToolProperty] = [:]
        for (key, param) in schema.parameters {
            properties[key] = ToolProperty(
                type: param.type,
                description: param.description
            )
        }

        let required = schema.parameters.filter { $0.value.required }.map { $0.key }

        return ToolParameters(
            properties: properties,
            required: required
        )
    }

    init(executablePath: String, schema: ExternalToolSchema, timeout: TimeInterval = 30.0) {
        self.name = schema.name
        self.description = schema.description
        self.executablePath = executablePath
        self.schema = schema
        self.timeout = timeout
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments to validate
        guard let data = arguments.data(using: .utf8) else {
            return .failure("Invalid UTF-8 in arguments")
        }

        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)

        let stdinPipe = Pipe()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.standardInput = stdinPipe
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Write JSON to stdin
        do {
            try stdinPipe.fileHandleForWriting.write(contentsOf: data)
            try stdinPipe.fileHandleForWriting.close()
        } catch {
            return .failure("Failed to write to stdin: \(error.localizedDescription)")
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
            if Date().timeIntervalSince(startTime) > timeout {
                process.terminate()
                return .failure("Tool timed out after \(timeout) seconds")
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }

        // Read output
        let stdoutData = try stdoutPipe.fileHandleForReading.readToEnd() ?? Data()
        let stderrData = try stderrPipe.fileHandleForReading.readToEnd() ?? Data()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        // Check exit code
        if process.terminationStatus != 0 {
            var errorMsg = "Tool failed with exit code \(process.terminationStatus)"
            if !stderr.isEmpty {
                errorMsg += "\nStderr: \(stderr)"
            }
            return .failure(errorMsg)
        }

        // Parse JSON response
        guard let responseData = stdout.data(using: .utf8) else {
            return .failure("Tool output is not valid UTF-8")
        }

        do {
            let response = try JSONDecoder().decode(ExternalToolResponse.self, from: responseData)
            if response.success {
                return .success(response.result ?? "")
            } else {
                return .failure(response.error ?? "Unknown error")
            }
        } catch {
            // If JSON parsing fails, return raw output
            return .success(stdout)
        }
    }
}
