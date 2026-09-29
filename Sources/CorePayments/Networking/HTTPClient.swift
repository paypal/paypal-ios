import Foundation

/// Abstracts request execution so `HTTPNetworkingClient` can be tested against REST/GraphQL request
/// construction (URLs, headers, body encoding) without simulating `URLSession` behavior.
protocol HTTPClient {

    func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse
}
