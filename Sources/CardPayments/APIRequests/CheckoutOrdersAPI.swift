import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

class CheckoutOrdersAPI {
    
    let coreConfig: CoreConfig
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
        
    func confirmPaymentSource(clientID: String, cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse {
        let apiClient = APIClient(coreConfig: coreConfig)
        
        let confirmData = ConfirmPaymentSourceRequest(cardRequest: cardRequest)
        
        let base64EncodedCredentials = Data(clientID.appending(":").utf8).base64EncodedString()
        
        // encode the body -- todo move
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(confirmData) // handle with special
        
        let restRequest = RESTRequest(
            path: "/v2/checkout/orders/\(cardRequest.orderID)/confirm-payment-source",
            method: .post,
            headers: [
                .contentType: "application/json", .acceptLanguage: "en_US",
                .authorization: "Basic \(base64EncodedCredentials)"
            ],
            queryParameters: nil,
            body: body
        )
        
        let httpResponse = try await apiClient.fetch(request: restRequest)
        return try HTTPResponseParser().parse(httpResponse, as: ConfirmPaymentSourceResponse.self)
    }
}
