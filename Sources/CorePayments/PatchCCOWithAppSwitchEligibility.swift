import Foundation

/// This class coordinates networking logic for communicating with the /graphql API for patching CCO with app switch eligibility.
@_documentation(visibility: private)
public class PatchCCOWithAppSwitchEligibility {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    private let authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI

    private let patchCCOQuery = """
        mutation PatchCcoWithAppSwitchEligibility(
            $contextId: String!,
            $experimentationContext: externalExperimentationContextInput,
            $osType: externalOSType!,
            $merchantOptInForAppSwitch: Boolean!,
            $paypalNativeAppInstalled: Boolean!,
            $token: externalToken!,
            $tokenType: externalTokenType!,
            $integrationArtifact: externalIntegrationArtifactType!
        ) {
            external {
                patchCcoWithAppSwitchEligibility(
                    appSwitchEligibilityInput: {
                        contextId: $contextId,
                        experimentationContext: $experimentationContext,
                        merchantOptInForAppSwitch: $merchantOptInForAppSwitch,
                        paypalNativeAppInstalled: $paypalNativeAppInstalled,
                        osType: $osType,
                        token: $token,
                        tokenType: $tokenType
                    },
                    patchCcoInput: {
                        token: $token,
                        clientConfig: {
                            integrationArtifact: $integrationArtifact
                        }
                    }
                ) {
                    appSwitchEligibility {
                        appSwitchEligible
                        redirectURL
                        ineligibleReason
                    }
                }
            }
        }
        """

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
        canSwitchToApp paypalNativeAppInstalled: Bool = true
    ) async throws -> AppSwitchEligibility {

        let lsat = try await authenticationSecureTokenServiceAPI.createLowScopedAccessToken().accessToken
        print("Test sending paypalNativeAppInstalled as \(paypalNativeAppInstalled)")
        let variables = PatchCcoWithAppSwitchEligibilityVariables(
            contextId: token,
            experimentationContext: ExperimentationContext(integrationChannel: PayPalCoreConstants.integrationChannel),
            osType: PayPalCoreConstants.osType,
            merchantOptInForAppSwitch: true,
            token: token,
            tokenType: tokenType,
            integrationArtifact: PayPalCoreConstants.integrationArtifact,
            paypalNativeAppInstalled: paypalNativeAppInstalled
        )

        let graphQLRequest = GraphQLRequest(
            query: patchCCOQuery,
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
