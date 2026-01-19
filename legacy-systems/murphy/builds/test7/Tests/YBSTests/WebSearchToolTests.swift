import Testing
import Foundation
@testable import YBS

@Suite("WebSearch Tool Tests")
struct WebSearchToolTests {

    // MARK: - Schema Discovery Tests

    @Test("web_search tool provides valid schema")
    func webSearchToolSchema() async throws {
        // Given: web_search tool exists and is executable
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath

        // When: Requesting schema
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        process.arguments = ["--schema"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        // Then: Schema should be valid JSON with required fields
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let schema = try JSONDecoder().decode(ExternalToolSchema.self, from: data)
        #expect(schema.name == "web_search")
        #expect(schema.parameters["query"] != nil)
        #expect(schema.parameters["query"]?.required == true)
        #expect(schema.parameters["max_results"] != nil)
    }

    // MARK: - Valid Query Tests

    @Test("web_search returns results for valid query")
    func webSearchValidQuery() async throws {
        // Given: A simple search query
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "Swift programming language", "max_results": 3}
        """

        // When: Executing search via Process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should return success with results
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == true)
        #expect(response.result?.contains("Result") ?? false)
    }

    // MARK: - Parameter Tests

    @Test("web_search handles max_results parameter")
    func webSearchMaxResults() async throws {
        // Given: Query with max_results = 2
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "test", "max_results": 2}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should respect max_results limit
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == true)
        #expect(response.metadata?["results_count"] == "2")
    }

    @Test("web_search defaults to 5 results when max_results not specified")
    func webSearchDefaultMaxResults() async throws {
        // Given: Query without max_results
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "test"}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should default to 5 results
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == true)
        #expect(response.metadata?["results_count"] == "5")
    }

    // MARK: - Error Handling Tests

    @Test("web_search handles empty query gracefully")
    func webSearchEmptyQuery() async throws {
        // Given: Empty query
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": ""}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should return error
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == false)
        #expect(response.error?.contains("required") ?? false)
    }

    @Test("web_search validates max_results lower bound")
    func webSearchMaxResultsLowerBound() async throws {
        // Given: max_results = 0 (below minimum)
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "test", "max_results": 0}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should clamp to minimum 1
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == true)
        #expect(response.metadata?["results_count"] == "1")
    }

    @Test("web_search validates max_results upper bound")
    func webSearchMaxResultsUpperBound() async throws {
        // Given: max_results = 100 (above maximum)
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "test", "max_results": 100}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Should cap at maximum 10
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.success == true)
        #expect(response.metadata?["results_count"] == "10")
    }

    // MARK: - Integration Tests

    @Test("web_search tool auto-discovers via ToolDiscovery")
    func webSearchAutoDiscovery() async throws {
        // Given: ToolDiscovery with search paths
        let logger = Logger(subsystem: "com.yelich.ybs", category: "test")
        let discovery = ToolDiscovery(
            toolPaths: ["~/.config/ybs/tools"],
            logger: logger
        )

        // When: Discovering tools
        let tools = await discovery.discoverTools()

        // Then: web_search should be discovered
        let webSearchTool = tools.first { $0.schema.name == "web_search" }
        #expect(webSearchTool != nil, "web_search tool should be auto-discovered")
    }

    @Test("web_search tool executes via ExternalTool wrapper")
    func webSearchExternalToolExecution() async throws {
        // Given: ExternalTool wrapper for web_search
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let schema = ExternalToolSchema(
            name: "web_search",
            description: "Search the web",
            parameters: [:]
        )
        let tool = ExternalTool(executablePath: toolPath, schema: schema)

        // When: Executing via wrapper
        let query = """
        {"query": "test query"}
        """
        let result = try await tool.execute(arguments: query)

        // Then: Should return successful result
        #expect(result.success == true)
        #expect(result.output != nil)
    }

    // MARK: - Response Format Tests

    @Test("web_search response contains required metadata")
    func webSearchResponseMetadata() async throws {
        // Given: Valid query
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "Swift"}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Response should contain required metadata
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        #expect(response.metadata?["query"] == "Swift")
        #expect(response.metadata?["search_engine"] != nil)
        #expect(response.metadata?["results_count"] != nil)
    }

    @Test("web_search result format is LLM-friendly")
    func webSearchResultFormat() async throws {
        // Given: Valid query
        let toolPath = NSString(string: "~/.config/ybs/tools/web_search").expandingTildeInPath
        let query = """
        {"query": "test"}
        """

        // When: Executing search
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()
        inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
        try inputPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        // Then: Result should be formatted with numbered list
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = try JSONDecoder().decode(ExternalToolResponse.self, from: data)
        let result = response.result ?? ""
        #expect(result.contains("1."), "Result should contain numbered list")
        #expect(result.contains("URL:"), "Result should contain URLs")
    }
}
