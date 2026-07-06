import Foundation

@_documentation(visibility: private)
public class AuthenticationSecureTokenServiceAPI {

    // MARK: - Private Properties

    private var coreConfig: CoreConfig
    private var networkingClient: NetworkingClient

    // MARK: - Initializer

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    public func createLowScopedAccessToken() async throws -> AuthTokenResponse {
        let restRequest = RESTRequest(
            path: "v1/oauth2/token",
            method: .post,
            postParameters: "grant_type=client_credentials&response_type=token",
            contentType: .formURLEncoded
        )

        let httpResponse = try await networkingClient.fetch(request: restRequest)
        return try HTTPResponseParser().parseREST(httpResponse, as: AuthTokenResponse.self)
    }
}
