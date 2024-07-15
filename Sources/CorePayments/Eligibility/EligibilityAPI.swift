import Foundation

/// API that return merchant's eligibility for different payment methods: Venmo, PayPal, PayPal Credit, Pay Later & credit card
class EligibilityAPI {
    
    // MARK: - Private Propertires
    
    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    
    // MARK: - Initializer
    
    /// Initialize the eligibility API to check for payment methods eligibility
    /// - Parameter coreConfig: configuration object
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }
    
    /// Checks merchants eligibility for different payment methods.
    /// - Returns: An `EligibilityResponse` containing the result of the eligibility check.
    func check(_ eligibilityRequest: EligibilityRequest) async throws -> EligibilityResponse {
        let variables = EligibilityVariables(eligibilityRequest: eligibilityRequest, clientID: coreConfig.clientID)
        let graphQLRequest = GraphQLRequest(query: Self.rawQuery, variables: variables)
        let httpResponse = try await networkingClient.fetch(request: graphQLRequest)
        
        return try HTTPResponseParser().parseGraphQL(httpResponse, as: EligibilityResponse.self)
    }
}

extension EligibilityAPI {
    
    static let rawQuery = """
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
