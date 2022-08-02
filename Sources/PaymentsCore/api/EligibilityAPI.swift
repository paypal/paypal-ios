import Foundation

public class EligibilityAPI {

    private let graphQLClient: GraphQLClient
    private let apiClient: APIClient
    private let coreConfig: CoreConfig

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

    public func checkEligibility() async throws -> Result<Eligibility, Error> {
        let clientId = try await apiClient.getClientId()
        let fundingEligibilityQuery = FundingEligibilityQuery(
            clientId: clientId,
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
