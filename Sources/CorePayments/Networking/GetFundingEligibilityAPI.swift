import Foundation

/// This class coordinates networking logic for the GetFundingEligibility GraphQL query.
@_documentation(visibility: private)
public class GetFundingEligibilityAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    private let authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI

    private let getFundingEligibilityQuery = """
        query GetFundingEligibility(
            $clientId: String!,
            $intent: FundingEligibilityIntent!,
            $currency: SupportedCountryCurrencies!,
            $enableFunding: [SupportedPaymentMethodsType]
        ) {
            fundingEligibility(
                clientId: $clientId,
                intent: $intent,
                currency: $currency,
                enableFunding: $enableFunding
            ) {
                venmo {
                    eligible
                    reasons
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

    /// Exposed for injecting mocks in tests
    init(
        coreConfig: CoreConfig,
        networkingClient: NetworkingClient,
        authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI
    ) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
        self.authenticationSecureTokenServiceAPI = authenticationSecureTokenServiceAPI
    }

    // MARK: - Public Methods

    /// Checks whether Venmo is eligible as a funding source.
    /// - Parameters:
    ///   - intent: The payment intent (e.g. "capture" or "authorize").
    ///   - currency: The currency code (e.g. "USD").
    ///   - enableFunding: Funding sources to check eligibility for (e.g. ["VENMO"]).
    /// - Returns: A `VenmoFundingEligibility` indicating whether Venmo is eligible.
    public func getFundingEligibility(
        intent: String,
        currency: String,
        enableFunding: [String]
    ) async throws -> VenmoFundingEligibility {

        let lsat = try await authenticationSecureTokenServiceAPI.createLowScopedAccessToken().accessToken

        let variables = GetFundingEligibilityVariables(
            clientId: coreConfig.clientID,
            intent: intent,
            currency: currency,
            enableFunding: enableFunding
        )

        let graphQLRequest = GraphQLRequest(
            query: getFundingEligibilityQuery,
            variables: variables,
            queryNameForURL: "GetFundingEligibility"
        )

        let httpResponse = try await networkingClient.fetch(
            request: graphQLRequest,
            additionalHeaders: [.authorization: "Bearer \(lsat)"]
        )

        let parsed: GetFundingEligibilityResponse =
            try HTTPResponseParser().parseGraphQL(httpResponse, as: GetFundingEligibilityResponse.self)

        guard let eligibility = parsed.fundingEligibility?.venmo else {
            throw NetworkingError.noGraphQLDataKey
        }

        return eligibility
    }
}
