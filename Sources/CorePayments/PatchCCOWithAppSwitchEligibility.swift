import Foundation

/// This class coordinates networking logic for communicating with the /graphql API for patching CCO with app switch eligibility.
@_documentation(visibility: private)
public class PatchCCOWithAppSwitchEligibility {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    private let patchCCOQuery = """
        mutation PatchCcoWithAppSwitchEligibility(
            $contextId: String!,
            $experimentationContext: externalExperimentationContextInput,
            $osType: externalOSType!,
            $merchantOptInForAppSwitch: Boolean!,
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
    }

    /// Exposed for injecting MockNetworkingClient in tests
    init(
        coreConfig: CoreConfig,
        networkingClient: NetworkingClient,
    ) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    public func patchCCOWithAppSwitchEligibility(
        token: String,
        tokenType: String
    ) async throws -> AppSwitchEligibility {

        let variables = PatchCcoWithAppSwitchEligibilityVariables(
            contextId: token,
            experimentationContext: ExperimentationContext(integrationChannel: "PPCP_NATIVE_SDK"),
            osType: "IOS",
            merchantOptInForAppSwitch: true,
            token: token,
            tokenType: tokenType,
            integrationArtifact: "MOBILE_SDK",
            paypalNativeAppInstalled: true
        )

        let graphQLRequest = GraphQLRequest(
            query: patchCCOQuery,
            variables: variables,
            queryNameForURL: nil
        )

        let httpResponse = try await networkingClient.fetch(
            request: graphQLRequest,
            clientContext: token,
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
