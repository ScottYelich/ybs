import Testing
@testable import YBS

@Suite("RunShellTool Tests")
struct RunShellToolTests {

    // MARK: - Working Directory Tests

    /// Test that shell commands run in the specified working directory
    @Test("Shell commands run in specified working directory")
    func shellCommandWorkingDirectory() async throws {
        let tool = RunShellTool()
        // Given: A test directory with a known file
        let testDir = "/tmp/test_shell_wd_\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(atPath: testDir)
        }

        try "test content".write(toFile: "\(testDir)/test.txt", atomically: true, encoding: .utf8)

        // When: Running ls in that directory
        let arguments = """
        {"command": "ls test.txt", "working_dir": "\(testDir)"}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Command should succeed and find the file
        #expect(result.success, "Shell command should succeed")
        #expect(result.output?.contains("test.txt") ?? false, "Output should contain test.txt")
    }

    /// Test that shell commands run in current directory when working_dir not specified
    @Test("Shell commands default to current directory")
    func shellCommandDefaultsToCurrentDirectory() async throws {
        let tool = RunShellTool()
        // Given: Current directory
        let currentDir = FileManager.default.currentDirectoryPath

        // When: Running pwd without working_dir
        let arguments = """
        {"command": "pwd"}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Should run in current directory
        #expect(result.success, "Shell command should succeed")
        #expect(result.output?.contains(currentDir) ?? false,
                      "Output should contain current directory: \(currentDir)")
    }

    /// Test that working_dir with tilde expansion works
    @Test("Shell commands expand tilde in working_dir")
    func shellCommandTildeExpansion() async throws {
        let tool = RunShellTool()
        // When: Running command with ~/
        let arguments = """
        {"command": "pwd", "working_dir": "~"}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Should expand to home directory
        let homeDir = NSString(string: "~").expandingTildeInPath
        #expect(result.success, "Shell command should succeed")
        #expect(result.output?.contains(homeDir) ?? false,
                      "Output should contain expanded home directory")
    }

    // MARK: - Basic Execution Tests

    @Test("Shell commands execute successfully")
    func shellCommandSuccess() async throws {
        let tool = RunShellTool()
        // When: Running simple echo command
        let arguments = """
        {"command": "echo 'Hello World'"}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Should succeed with output
        #expect(result.success)
        #expect(result.output?.contains("Hello World") ?? false)
    }

    @Test("Shell commands report failure correctly")
    func shellCommandFailure() async throws {
        let tool = RunShellTool()
        // When: Running command that fails
        let arguments = """
        {"command": "exit 1"}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Should report failure
        #expect(!result.success)
        #expect(result.output?.contains("Exit code: 1") ?? false)
    }

    @Test("Shell commands timeout after specified duration")
    func shellCommandTimeout() async throws {
        let tool = RunShellTool()
        // When: Running command that exceeds timeout
        let arguments = """
        {"command": "sleep 10", "timeout": 1}
        """
        let result = try await tool.execute(arguments: arguments)

        // Then: Should timeout
        #expect(!result.success)
        #expect(result.error?.contains("timed out") ?? false)
    }

    // MARK: - Security Tests (placeholder - not yet implemented)

    @Test("Blocked commands should be rejected", .disabled("Blocked command validation not yet implemented"))
    func shellCommandBlockedCommands() async throws {
        let tool = RunShellTool()
        // NOTE: Blocked command validation not yet implemented
        // This test documents expected behavior

        // Given: A dangerous command
        let arguments = """
        {"command": "rm -rf /"}
        """

        // When/Then: Should be blocked
        // TODO: Implement blocked command validation
        // let result = try await tool.execute(arguments: arguments)
        // #expect(!result.success)
        // #expect(result.error?.contains("blocked") ?? false)
    }
}
