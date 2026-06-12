import Foundation

public protocol PatchCCOAPIProtocol {
    func patchCCOWithAppSwitchEligibility(
        token: String,
        tokenType: String,
        paypalNativeAppInstalled: Bool
    ) async throws -> AppSwitchEligibility
}

/// This class coordinates networking logic for communicating with the /graphql API for patching CCO with app switch eligibility.
@_documentation(visibility: private)
public class PatchCCOWithAppSwitchEligibility: PatchCCOAPIProtocol {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    private let authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI

    // MARK: - Initializer

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
        self.authenticationSecureTokenServiceAPI = AuthenticationSecureTokenServiceAPI(coreConfig: coreConfig)
    }

    /// Exposed for injecting MockNetworkingClient in tests
    init(
        coreConfig: CoreConfig,
        networkingClient: NetworkingClient,
        authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI
    ) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
        self.authenticationSecureTokenServiceAPI = authenticationSecureTokenServiceAPI
    }

    // MARK: - Internal Methods

    public func patchCCOWithAppSwitchEligibility(
        token: String,
        tokenType: String,
        paypalNativeAppInstalled: Bool
    ) async throws -> AppSwitchEligibility {

        let lsat = try await authenticationSecureTokenServiceAPI.createLowScopedAccessToken().accessToken

        let variables = PatchCcoWithAppSwitchEligibilityVariables(
            contextId: token,
            experimentationContext: ExperimentationContext(integrationChannel: PayPalCoreConstants.integrationChannel),
            osType: PayPalCoreConstants.platform,
            merchantOptInForAppSwitch: true,
            token: token,
            tokenType: tokenType,
            integrationArtifact: PayPalCoreConstants.integrationArtifact,
            paypalNativeAppInstalled: paypalNativeAppInstalled
        )

        let graphQLRequest = GraphQLRequest(
            query: GraphQLQueries.patchCCOWithAppSwitchEligibility,
            variables: variables,
            queryNameForURL: nil
        )

        let httpResponse = try await networkingClient.fetch(
            request: graphQLRequest,
            clientContext: token,
            additionalHeaders: [.authorization: "Bearer \(lsat)"]
        )

        let parsed: PatchCcoWithAppSwitchEligibilityResponse =
        try HTTPResponseParser().parseGraphQL(httpResponse, as: PatchCcoWithAppSwitchEligibilityResponse.self)

        guard
            let eligibility = parsed.external?
                .patchCcoWithAppSwitchEligibility?
                .appSwitchEligibility
        else {
            throw NetworkingError.noGraphQLDataKey
        }

        return eligibility
    }
}
