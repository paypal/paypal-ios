import Foundation

/// This is a protocol for function performing urlRequest in HTTP class and in GraphQLClient
@_documentation(visibility: private)
public protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}
