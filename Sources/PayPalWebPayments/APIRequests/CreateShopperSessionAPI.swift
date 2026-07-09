import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Coordinates the GraphQL call that pre-warms a Shopper Session with app-switch eligibility.
@_documentation(visibility: private)
class CreateShopperSessionAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    private let createShopperSessionQuery = """
        mutation CreateShopperSessionWithAppSwitchEligibility(
            $returnUrl: String!,
            $cancelUrl: String!,
            $fallbackSchemeUrl: String,
            $userAction: String!,
            $osType: String!,
            $integrationArtifact: String!,
            $integrationChannel: String,
            $userIdentity: UserIdentityInput
        ) {
            external {
                createShopperSessionWithAppSwitchEligibility(
                    input: {
                        urlConfig: {
                            returnUrl: $returnUrl,
                            cancelUrl: $cancelUrl,
                            fallbackSchemeUrl: $fallbackSchemeUrl
                        },
                        userAction: $userAction,
                        osType: $osType,
                        integrationArtifact: $integrationArtifact,
                        integrationChannel: $integrationChannel,
                        userIdentity: $userIdentity
                    }
                ) {
                    appSwitchEligible
                    redirectURL
                    checkoutFallbackUrl
                    ineligibleReason
                    matchedAuthenticationMethods
                    shopperSessionConfig {
                        id
                        expiresAt
                    }
                }
            }
        }
        """

    // MARK: - Initializer

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    /// Exposed for injecting `MockNetworkingClient` in tests.
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    /// Creates a Shopper Session with app-switch eligibility and returns the full result.
    /// - Parameters:
    ///   - urlConfig: Return and cancel deep-link URLs registered with PayPal.
    ///   - userIdentity: Optional buyer identity for the session.
    ///   - userAction: The buyer action intent (default `.continue`).
    /// - Returns: A `ShopperSessionResult` containing eligibility, redirect URL, and session config.
    /// - Throws: A `CoreSDKError` if the network call or response parsing fails.
    func createShopperSessionWithAppSwitchEligibility(
        urlConfig: PayPalURLConfig,
        userIdentity: PayPalUserIdentity?,
        userAction: PayPalUserAction
    ) async throws -> ShopperSessionResult {
        // TODO: for testing purposes only, will be removed
        return FakeCreateShopperSessionSuccessResponse.success
        
        let identityVariables = userIdentity.map(UserIdentityVariables.init)

        let variables = CreateShopperSessionVariables(
            returnUrl: urlConfig.returnAppURL,
            cancelUrl: urlConfig.cancelAppURL,
            fallbackSchemeUrl: urlConfig.fallbackSchemeURL,
            userAction: userAction.graphQLValue,
            osType: PayPalCoreConstants.osType,
            integrationArtifact: PayPalCoreConstants.integrationArtifact,
            integrationChannel: PayPalCoreConstants.integrationChannel,
            userIdentity: identityVariables
        )

        let graphQLRequest = GraphQLRequest(
            query: createShopperSessionQuery,
            variables: variables,
            queryNameForURL: nil
        )

        let httpResponse = try await networkingClient.fetch(request: graphQLRequest)

        let parsed: CreateShopperSessionResponse = try HTTPResponseParser()
            .parseGraphQL(httpResponse, as: CreateShopperSessionResponse.self)

        guard let result = parsed.external?.shopperSession else {
            throw NetworkingError.noGraphQLDataKey
        }

        return result
    }
}
