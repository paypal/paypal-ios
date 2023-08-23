import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the v2/checkout/orders API.
///
/// Details on this PayPal API can be found in PPaaS under Merchant > Checkout > Orders > v2.
class CheckoutOrdersAPI {
    
    // MARK: - Private Propertires
    
    private let coreConfig: CoreConfig
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
    
    // MARK: - Internal Methods
        
    func confirmPaymentSource(cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse {
        let apiClient = APIClient(coreConfig: coreConfig)
        
        let confirmData = ConfirmPaymentSourceRequest(cardRequest: cardRequest)
        
        let restRequest = RESTRequest(
            path: "/v2/checkout/orders/\(cardRequest.orderID)/confirm-payment-source",
            method: .post,
            queryParameters: nil,
            postParameters: confirmData
        )
        
        let httpResponse = try await apiClient.fetch(request: restRequest)
        return try HTTPResponseParser().parse(httpResponse, as: ConfirmPaymentSourceResponse.self)
    }
}
