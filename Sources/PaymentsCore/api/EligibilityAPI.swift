import Foundation

public class EligibilityAPI {

    internal var graphQLClient: GraphQLClient
    private var coreConfig: CoreConfig
    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        graphQLClient = GraphQLClient(environment: coreConfig.environment)
    }

    public func checkEligibility() async throws -> Result<Eligibility, Error> {
        let fundingEligibilityQuery = FundingEligibilityQuery(
            clientId: coreConfig.clientID,
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
