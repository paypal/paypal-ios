import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the v2/checkout/orders API.
///
/// Details on this PayPal API can be found in PPaaS under Merchant > Checkout > Orders > v2.
class CheckoutOrdersAPI {
    
    // MARK: - Internal Properties

    var correlationID: String?

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let apiClient: APIClient
    
    // MARK: - Initializer
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.apiClient = APIClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockAPIClient in tests
    init(coreConfig: CoreConfig, apiClient: APIClient) {
        self.coreConfig = coreConfig
        self.apiClient = apiClient
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
        
        let httpResponse = try await apiClient.fetch(request: restRequest)
        let httpResponseBodyJSON = try? JSONSerialization.jsonObject(with: httpResponse.body ?? Data()) as? [String: Any]
        correlationID = httpResponseBodyJSON?["debug_id"] as? String

        return try HTTPResponseParser().parseREST(httpResponse, as: ConfirmPaymentSourceResponse.self)
    }
}
