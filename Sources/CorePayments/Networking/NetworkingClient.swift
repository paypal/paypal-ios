import Foundation

/// Protocol defining the interface for performing REST and GraphQL network requests.
@_documentation(visibility: private)
public protocol NetworkingClient {

    func fetch(request: RESTRequest) async throws -> HTTPResponse
    func fetch(request: GraphQLRequest, clientContext: String?) async throws -> HTTPResponse
}
