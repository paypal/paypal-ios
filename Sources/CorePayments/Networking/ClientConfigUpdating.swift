import Foundation

/// Protocol defining the interface for updating client configuration via the GraphQL API.
@_documentation(visibility: private)
public protocol ClientConfigUpdating {

    func updateClientConfig(token: String, fundingSource: String) async throws -> ClientConfigResponse
}
