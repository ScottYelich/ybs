import Testing
@testable import YBS

@Suite struct WriteFileToolTests {
    @Test func toolMetadata() {
        let tool = WriteFileTool()

        #expect(tool.name == "write_file")
        #expect(tool.description.contains("Write"))
        #expect(tool.parameters.required == ["path", "content"])
    }

    @Test func writeFileBasic() async throws {
        let testPath = "/tmp/ybs-test-write.txt"

        // Remove if exists
        try? FileManager.default.removeItem(atPath: testPath)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "Hello, World!"
        }
        """

        let result = try await tool.execute(arguments: args)

        #expect(result.success)

        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: testPath))

        // Verify content
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        #expect(content == "Hello, World!")
    }

    @Test func writeFileOverwrite() async throws {
        let testPath = "/tmp/ybs-test-overwrite.txt"

        // Create initial file
        try "Initial content".write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "New content"
        }
        """

        let result = try await tool.execute(arguments: args)

        #expect(result.success)

        // Verify content was overwritten
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        #expect(content == "New content")
    }

    @Test func writeFileWithDirectories() async throws {
        let testDir = "/tmp/ybs-test-nested"
        let testPath = "\(testDir)/subdir/file.txt"

        // Remove if exists
        try? FileManager.default.removeItem(atPath: testDir)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "Nested file content"
        }
        """

        let result = try await tool.execute(arguments: args)

        #expect(result.success)

        // Verify file was created
        #expect(FileManager.default.fileExists(atPath: testPath))

        // Verify content
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        #expect(content == "Nested file content")
    }

    @Test func writeFileMultiline() async throws {
        let testPath = "/tmp/ybs-test-multiline.txt"
        try? FileManager.default.removeItem(atPath: testPath)

        let tool = WriteFileTool()
        let multilineContent = """
        Line 1
        Line 2
        Line 3
        """

        let args = """
        {
            "path": "\(testPath)",
            "content": "\(multilineContent.replacingOccurrences(of: "\n", with: "\\n"))"
        }
        """

        let result = try await tool.execute(arguments: args)

        #expect(result.success)

        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        #expect(content.split(separator: "\n").count == 3)
    }
}
