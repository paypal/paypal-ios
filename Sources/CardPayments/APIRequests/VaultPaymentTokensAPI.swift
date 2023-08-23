import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the /graphql?UpdateVaultSetupToken API.
///
/// Details on this PayPal API can be found in PPaaS under Merchant > Data Vault > Payment Method Tokens > v3.
class VaultPaymentTokensAPI {
    
    // MARK: - Private Propertires
    
    private let coreConfig: CoreConfig
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
    
    // MARK: - Internal Methods
        
    func updateSetupToken(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse {
        let apiClient = APIClient(coreConfig: coreConfig)
        
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
                        rel, href
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

        let httpResponse = try await apiClient.fetch(request: graphQLRequest)
        
        do {
            // TODO: - Move graphQL specific parsing logic into HTTPResponseParser
            let parsedResponse = try HTTPResponseParser().parse(httpResponse, as: GraphQLHTTPResponse<UpdateSetupTokenResponse>.self)
            if let graphQLResponseData = parsedResponse.data {
                return graphQLResponseData
            } else {
                throw CardClientError.encodingError // TODO
            }
        } catch {
            throw error // TODO
        }
    }
}
