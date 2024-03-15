import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the /graphql?UpdateVaultSetupToken API.
class VaultPaymentTokensAPI {
    
    // MARK: - Private Propertires
    
    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }
    
    // MARK: - Internal Methods
    
    func getEligibility() async {
        let queryString = """
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
        
//        let variables = UpdateVaultVariables(cardVaultRequest: cardVaultRequest, clientID: coreConfig.clientID)
        let variables = EligVar(clientId: coreConfig.clientID, intent: "CAPTURE")

        let graphQLRequest = GraphQLRequest(
            query: queryString,
            variables: variables,
            queryNameForURL: ""
        )

        let httpResponse = try? await networkingClient.fetch(request: graphQLRequest)
        print(httpResponse!.body!.prettyPrintedJSONString)
    }
    
    struct EligVar: Encodable {
        let clientId: String
        let intent: String
        let currency = "USD"
        let enableFunding = ["VENMO"]
    }
        
    func updateSetupToken(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse {
        
        let queryString = """
            mutation UpdateVaultSetupToken(
                $clientID: String!,
                $vaultSetupToken: String!,
                $paymentSource: PaymentSource
            ) {
                updateVaultSetupToken(
                    clientId: $clientID
                    vaultSetupToken: $vaultSetupToken
                    paymentSource: $paymentSource
                ) {
                    id,
                    status,
                    links {
                        rel,
                        href
                    }
                }
            }
        """
        
        let variables = UpdateVaultVariables(cardVaultRequest: cardVaultRequest, clientID: coreConfig.clientID)

        let graphQLRequest = GraphQLRequest(
            query: queryString,
            variables: variables,
            queryNameForURL: "UpdateVaultSetupToken"
        )

        let httpResponse = try await networkingClient.fetch(request: graphQLRequest)
        
        return try HTTPResponseParser().parseGraphQL(httpResponse, as: UpdateSetupTokenResponse.self)
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
