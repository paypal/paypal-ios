import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the v2/checkout/orders API.
///
/// Details on this PayPal API can be found in PPaaS under Merchant > Checkout > Orders > v2.
class CheckoutOrdersAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: HTTPNetworkingClient
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = HTTPNetworkingClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockHTTPNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: HTTPNetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }
    
    // MARK: - Internal Methods
        
    func confirmPaymentSource(cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse {
        let confirmData = ConfirmPaymentSourceRequest(cardRequest: cardRequest)
        
        let restRequest = RESTRequest(
            path: "/v2/checkout/orders/\(cardRequest.orderID)/confirm-payment-source",
            method: .post,
            queryParameters: nil,
            postParameters: confirmData
        )
        
        let httpResponse = try await networkingClient.fetch(request: restRequest)
        return try HTTPResponseParser().parseREST(httpResponse, as: ConfirmPaymentSourceResponse.self)
    }
}
