import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the v2/checkout/orders API.
///
/// Details on this PayPal API can be found in PPaaS under Merchant > Checkout > Orders > v2.
class VaultAPI {
    
    // MARK: - Private Propertires
    
    private let coreConfig: CoreConfig
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
    
    // MARK: - Internal Methods
        
    func vaultWithoutPurchase(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse {
        let apiClient = APIClient(coreConfig: coreConfig)

        // TODO: - Move JSON encoding into custom class, similar to HTTPResponseParser
        let variables = VaultDataEncodableVariables(cardVaultRequest: cardVaultRequest, clientID: coreConfig.clientID)
//        let variables: [String: Any] = [
//            "clientID": coreConfig.clientID,
//            "vaultSetupToken": cardVaultRequest.setupTokenID,
//            "paymentSource": [
//                "card": [
//                    "number": cardVaultRequest.card.number,
//                    "securityCode": cardVaultRequest.card.securityCode,
//                    "expiry": cardVaultRequest.card.expiry,
//                    "name": cardVaultRequest.card.cardholderName
//                ]
//            ]
//        ]
        
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
