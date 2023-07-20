import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: APIRequest {
    
    private let orderID: String
    private let pathFormat: String = "/v2/checkout/orders/%@/confirm-payment-source"
    private let base64EncodedCredentials: String
    var jsonEncoder: JSONEncoder
    
    /// Creates a request to attach a payment source to a specific order.
    /// In order to use this initializer, the `paymentSource` parameter has to
    /// contain the entire dictionary as it exists underneath the `payment_source` key.
    init(
        clientID: String,
        cardRequest: CardRequest,
        encoder: JSONEncoder = JSONEncoder() // exposed for test injection
    ) throws {
        self.jsonEncoder = encoder
        var confirmPaymentSource = ConfirmPaymentSource()
        var card = cardRequest.card
        let verification = Verification(method: cardRequest.sca.rawValue)
        card.attributes = Attributes(verification: verification)
            
        confirmPaymentSource.applicationContext = ApplicationContext(
            returnUrl: PayPalCoreConstants.callbackURLScheme + "://card/success",
            cancelUrl: PayPalCoreConstants.callbackURLScheme + "://card/cancel"
        )
        
        confirmPaymentSource.paymentSource = PaymentSource(
            card: card,
            scaType: cardRequest.sca,
            shouldVault: true // Extract from CardRequest
        )
        
        self.orderID = cardRequest.orderID
        self.base64EncodedCredentials = Data(clientID.appending(":").utf8).base64EncodedString()
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
            .authorization: "Basic \(base64EncodedCredentials)"
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
        
        var card: PaymentSource.Card
        
        struct Card: Encodable {
            
            var number: String
            var expiry: String
            var securityCode: String
            var cardholderName: String?
            var billingAddress: Address?
            var attributes: PaymentSource.Attributes
            var vault: PaymentSource.Vault
        }
        
        struct Attributes: Encodable {
            
            let verification: PaymentSource.Verification
        }
        
        struct Verification: Codable {

            let method: String
        }
        
        struct Vault: Encodable {
            
            let storeInVault: String?
        }
        
        init(card: CardPayments.Card, scaType: SCA, shouldVault: Bool) {
            self.card = PaymentSource.Card(
                number: card.number,
                expiry: card.expirationMonth + card.expirationYear,
                securityCode: card.securityCode,
                attributes: PaymentSource.Attributes(verification: Verification(method: scaType.rawValue)),
                vault: Vault(storeInVault: shouldVault ? "ON_SUCCESS" : nil))
        }
    }
}
