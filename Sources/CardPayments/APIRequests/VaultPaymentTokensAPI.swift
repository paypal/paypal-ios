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
