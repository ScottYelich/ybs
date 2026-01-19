// Implements: Step 12 (HTTP Client & OpenAI Types) + ybs-spec.md § 7 (LLM Provider Abstraction)
import Foundation

class HTTPClient {
    private let session: URLSession
    private let logger: Logger

    init(logger: Logger) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        self.session = URLSession(configuration: config)
        self.logger = logger
    }

    /// Make a POST request with JSON body
    func post(url: String, headers: [String: String], body: Data) async throws -> Data {
        guard let requestURL = URL(string: url) else {
            throw YBSError.invalidInput(field: "url", reason: "Invalid URL format")
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = body

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        logger.debug("POST \(url)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YBSError.llmConnectionFailed(
                    provider: "unknown",
                    error: "Invalid response type"
                )
            }

            logger.debug("Response status: \(httpResponse.statusCode)")

            // Handle error status codes
            if httpResponse.statusCode >= 400 {
                // Try to parse error response
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: apiError.error.message
                    )
                } else {
                    let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: errorText
                    )
                }
            }

            return data
        } catch let error as YBSError {
            throw error
        } catch {
            logger.error("HTTP request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: "unknown",
                error: error.localizedDescription
            )
        }
    }

    /// Stream a POST request (Server-Sent Events)
    func streamPost(
        url: String,
        headers: [String: String],
        body: Data,
        onChunk: @escaping (String) -> Void
    ) async throws {
        guard let requestURL = URL(string: url) else {
            throw YBSError.invalidInput(field: "url", reason: "Invalid URL format")
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = body

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        logger.debug("POST (stream) \(url)")

        do {
            let (bytes, response) = try await session.bytes(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YBSError.llmConnectionFailed(
                    provider: "unknown",
                    error: "Invalid response type"
                )
            }

            if httpResponse.statusCode >= 400 {
                // Read error response
                var errorData = Data()
                for try await byte in bytes {
                    errorData.append(byte)
                }

                if let apiError = try? JSONDecoder().decode(APIError.self, from: errorData) {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: apiError.error.message
                    )
                } else {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: "Request failed"
                    )
                }
            }

            // Parse SSE stream
            var buffer = ""
            for try await byte in bytes {
                buffer.append(String(UnicodeScalar(byte)))

                // SSE lines end with \n
                if buffer.hasSuffix("\n") {
                    let line = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                    buffer = ""

                    // SSE format: "data: {json}\n\n"
                    if line.hasPrefix("data: ") {
                        let data = String(line.dropFirst(6))
                        if data != "[DONE]" {
                            onChunk(data)
                        }
                    }
                }
            }
        } catch let error as YBSError {
            throw error
        } catch {
            logger.error("Streaming request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: "unknown",
                error: error.localizedDescription
            )
        }
    }
}
