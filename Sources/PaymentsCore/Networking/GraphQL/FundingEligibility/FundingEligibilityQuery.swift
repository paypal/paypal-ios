class FundingEligibilityQuery: GraphQLQuery {

    var query: String {
        return rawQuery
    }

    var variables: [String: Any] {
        return [
            paramClientId: clientID,
            paramIntent: fundingEligibilityIntent.rawValue,
            paramCurrency: currencyCode.rawValue,
            paramEnableFunding: enableFunding.toStringArray()
        ]
    }

    let clientID: String
    let fundingEligibilityIntent: FundingEligibilityIntent
    let currencyCode: SupportedCountryCurrencyType
    var enableFunding: [SupportedPaymentMethodsType]

    init(
        clientID: String,
        fundingEligibilityIntent: FundingEligibilityIntent,
        currencyCode: SupportedCountryCurrencyType,
        enableFunding: [SupportedPaymentMethodsType]
    ) {
        self.clientID = clientID
        self.fundingEligibilityIntent = fundingEligibilityIntent
        self.currencyCode = currencyCode
        self.enableFunding = enableFunding
    }

    let paramClientId = "clientId"
    let paramIntent = "intent"
    let paramCurrency = "currency"
    let paramEnableFunding = "enableFunding"

    private let rawQuery = """
        query getEligibility(
            $clientId: String!,
            $intent: FundingEligibilityIntent!,
            $currency: SupportedCountryCurrencies!,
            $enableFunding: [SupportedPaymentMethodsType]
        ){
            fundingEligibility(
                clientId: $clientId,
                intent: $intent
                currency: $currency,
                enableFunding: $enableFunding){
                venmo{
                    eligible
                    reasons
                }
                card{
                    eligible
                }
                paypal{
                    eligible
                    reasons
                }
                paylater{
                    eligible
                    reasons
                }
                credit{
                    eligible
                    reasons
                }
            }
        }
    """
}

extension Array
where Element == SupportedPaymentMethodsType {
    func toStringArray() -> [String] {
        var stringArray: [String] = []
        for element in self {
            stringArray += [element.rawValue]
        }
        return stringArray
    }
}
