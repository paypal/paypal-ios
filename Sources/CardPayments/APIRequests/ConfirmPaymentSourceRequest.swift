import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: APIRequest {
    
    private let orderID: String
    private let pathFormat: String = "/v2/checkout/orders/%@/confirm-payment-source"
    private let accessToken: String
    var jsonEncoder: JSONEncoder
    
    /// Creates a request to attach a payment source to a specific order.
    /// In order to use this initializer, the `paymentSource` parameter has to
    /// contain the entire dictionary as it exists underneath the `payment_source` key.
    
    init(
        accessToken: String,
        cardRequest: CardRequest,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        // encode with custom encoder that throws error if passed in
        self.jsonEncoder = encoder
        var confirmPaymentSource = ConfirmPaymentSource()
        var card = cardRequest.card
        let verification = Verification(method: cardRequest.sca.rawValue)
        card.attributes = Attributes(verification: verification)
            
        confirmPaymentSource.applicationContext = ApplicationContext(
            returnUrl: PayPalCoreConstants.callbackURLScheme + "://card/success",
            cancelUrl: PayPalCoreConstants.callbackURLScheme + "://card/cancel"
        )
        
        confirmPaymentSource.paymentSource = PaymentSource(card: card)
        
        self.orderID = cardRequest.orderID
        self.accessToken = accessToken
        
        path = String(format: pathFormat, orderID)
        
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            body = try jsonEncoder.encode(confirmPaymentSource)
        } catch {
            throw CardClientError.encodingError
        }
        
        // TODO - The complexity in this `init` signals to reconsider our use/design of the `APIRequest` protocol.
        // Existing pattern doesn't provide clear, testable interface for encoding JSON POST bodies.
    }
    
    // MARK: - APIRequest
    
    typealias ResponseType = ConfirmPaymentSourceResponse
    
    var path: String
    var method: HTTPMethod = .post
    var body: Data?
    
    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Bearer \(accessToken)"
        ]
    }
    
    private struct ConfirmPaymentSource: Encodable {
        
        var paymentSource: PaymentSource?
        var applicationContext: ApplicationContext?
    }
    
    private struct ApplicationContext: Encodable {
        
        let returnUrl: String
        let cancelUrl: String
    }
    
    private struct PaymentSource: Encodable {
        
        let card: Card
    }
}
