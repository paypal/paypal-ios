import Foundation

/// Protocol defining the interface for performing HTTP requests.
protocol HTTPClient {

    func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse
}
