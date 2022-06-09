import Foundation
import PaymentsCore

public class EligibilityAPI {

    private var graphQLClient: GraphQLClient
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
            return Result.success(
                Eligibility(
                    isVenmoEligible: response.data?.fundingEligibility.venmo.eligible ?? false,
                    isPaypalEligible: response.data?.fundingEligibility.paypal.eligible ?? false,
                    isPaypalCreditEligible: response.data?.fundingEligibility.credit.eligible ?? false,
                    isPayLaterEligible: response.data?.fundingEligibility.paylater.eligible ?? false,
                    isCreditCardEligible: response.data?.fundingEligibility.card.eligible ?? false)
            )
        }
    }
}
