// Implements: Step 24 (External Tool Protocol) + ybs-spec.md § 4 (External Tools)
import Foundation

/// External tool schema (from --schema flag)
struct ExternalToolSchema: Codable {
    let name: String
    let description: String
    let parameters: [String: ParameterSchema]
}

/// Parameter schema for external tools
struct ParameterSchema: Codable {
    let type: String
    let description: String
    let required: Bool

    enum CodingKeys: String, CodingKey {
        case type, description, required
    }
}

/// Tool response format from external tools
struct ExternalToolResponse: Codable {
    let success: Bool
    let result: String?
    let error: String?
    let metadata: [String: String]?
}
