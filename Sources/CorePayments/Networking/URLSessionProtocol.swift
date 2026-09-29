import Foundation

/// Abstracts `URLSession` so `URLSessionHTTPClient` can be tested without making real network calls.
@_documentation(visibility: private)
public protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}
