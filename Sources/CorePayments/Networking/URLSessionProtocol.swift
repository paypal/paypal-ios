import Foundation

/// :nodoc: This is a protocol for function performing urlRequest in HTTP class and in GraphQLClient
public protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}
