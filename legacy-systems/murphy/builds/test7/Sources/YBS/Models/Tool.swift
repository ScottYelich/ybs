// Implements: Step 6 (Core Data Models) + ybs-spec.md § 3 (Core Tools)
import Foundation

/// Represents a tool (function) that the LLM can call
struct Tool: Codable, Equatable {
    var type: String = "function"
    var function: ToolFunction

    struct ToolFunction: Codable, Equatable {
        var name: String
        var description: String
        var parameters: ToolParameters

        init(name: String, description: String, parameters: ToolParameters) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }

    init(name: String, description: String, parameters: ToolParameters) {
        self.function = ToolFunction(
            name: name,
            description: description,
            parameters: parameters
        )
    }
}

/// Tool parameters schema (JSON Schema format)
struct ToolParameters: Codable, Equatable {
    var type: String = "object"
    var properties: [String: ToolProperty]
    var required: [String]

    init(properties: [String: ToolProperty], required: [String] = []) {
        self.properties = properties
        self.required = required
    }
}

/// Individual tool parameter definition
struct ToolProperty: Codable, Equatable {
    var type: String
    var description: String
    var enumValues: [String]?

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case enumValues = "enum"
    }

    init(type: String, description: String, enumValues: [String]? = nil) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
    }
}
