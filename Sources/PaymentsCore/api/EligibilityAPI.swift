import Foundation

/// API that return merchant's elgibility for diferent payment methods: Venmo, PayPal, PayPalCredit, PayLater & credit card
public class EligibilityAPI {

    private let graphQLClient: GraphQLClient
    private let apiClient: APIClient
    private let coreConfig: CoreConfig

    /// Initialize the elgibility api to check for payment methods eligiblity
    public convenience init(coreConfig: CoreConfig) {
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

    /// Checks merchants elgibility for diferent payment methods.
    /// - Returns: Eligibility for payment methods.
    public func checkEligibility() async throws -> Result<Eligibility, Error> {
        let clientID = try await apiClient.getClientID()
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
