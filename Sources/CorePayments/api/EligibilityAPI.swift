import Foundation

/// API that return merchant's eligibility for different payment methods: Venmo, PayPal, PayPal Credit, Pay Later & credit card
class EligibilityAPI {

    private let graphQLClient: GraphQLClient
    private let apiClient: APIClient
    private let coreConfig: CoreConfig

    /// Initialize the eligibility API to check for payment methods eligibility
    /// - Parameter coreConfig: configuration object
    convenience init(coreConfig: CoreConfig) {
        self.init(
            coreConfig: coreConfig,
            apiClient: APIClient(coreConfig: coreConfig),
            graphQLClient: GraphQLClient(environment: coreConfig.environment)
        )
    }

    init(coreConfig: CoreConfig, apiClient: APIClient, graphQLClient: GraphQLClient) {
        self.coreConfig = coreConfig
        self.apiClient = apiClient
        self.graphQLClient = graphQLClient
    }

    /// Checks merchants eligibility for different payment methods.
    /// - Returns: a result object with either eligibility or an error
    func checkEligibility() async throws -> Result<Eligibility, Error> {
        let clientID = coreConfig.clientID
        let fundingEligibilityQuery = FundingEligibilityQuery(
            clientID: clientID,
            fundingEligibilityIntent: FundingEligibilityIntent.CAPTURE,
            currencyCode: SupportedCountryCurrencyType.USD,
            enableFunding: [SupportedPaymentMethodsType.VENMO]
        )
        let response: GraphQLQueryResponse<FundingEligibilityResponse>
            = try await graphQLClient.executeQuery(query: fundingEligibilityQuery)
        if response.data == nil {
            return Result.failure(GraphQLError(message: "error fetching eligibility", extensions: nil))
        } else {
            let eligibility = response.data?.fundingEligibility
            return Result.success(
                Eligibility(
                    isVenmoEligible: eligibility?.venmo.eligible ?? false,
                    isPaypalEligible: eligibility?.paypal.eligible ?? false,
                    isPaypalCreditEligible: eligibility?.credit.eligible ?? false,
                    isPayLaterEligible: eligibility?.paylater.eligible ?? false,
                    isCreditCardEligible: eligibility?.card.eligible ?? false)
            )
        }
    }
}
