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
        
        confirmPaymentSource.applicationContext = ApplicationContext(
            returnUrl: PayPalCoreConstants.callbackURLScheme + "://card/success",
            cancelUrl: PayPalCoreConstants.callbackURLScheme + "://card/cancel"
        )

        confirmPaymentSource.paymentSource = PaymentSource(
            card: cardRequest.card,
            scaType: cardRequest.sca,
            vault: cardRequest.vault
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
    
    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
        case name
        case billingAddress
        case attributes
    }
    
    private struct EncodedCard: Encodable {
        
        let number: String
        let securityCode: String
        let billingAddress: Address?
        let name: String?
        let expiry: String
        let attributes: Attributes?
                
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(number, forKey: .number)
            try container.encode(expiry, forKey: .expiry)
            try container.encode(securityCode, forKey: .securityCode)
            try container.encode(name, forKey: .name)
            try container.encode(billingAddress, forKey: .billingAddress)
            try container.encode(attributes, forKey: .attributes)
        }
    }
    
    private struct Verification: Encodable {
        
        let method: String
    }
    
    private  struct CardVault: Encodable {
        
        let storeInVault: String?
    }
    
    private struct Customer: Encodable {
        
        let id: String
    }
    
    private struct Attributes: Encodable {
        
        var customer: Customer?
        var vault: CardVault?
        let verification: Verification
        
        init(vault: Vault? = nil, verificationMethod: String) {
            self.verification = Verification(method: verificationMethod)
            if let vault {
                self.vault = CardVault(storeInVault: "ON_SUCCESS")
                if let id = vault.customerID {
                    self.customer = Customer(id: id)
                }
            }
        }
    }
    
    private struct PaymentSource: Encodable {
        
        let card: EncodedCard
        
        init(card: Card, scaType: SCA, vault: Vault?) {
            self.card = EncodedCard(
                number: card.number,
                securityCode: card.securityCode,
                billingAddress: card.billingAddress,
                name: card.cardholderName,
                expiry: "\(card.expirationYear)-\(card.expirationMonth)",
                attributes: Attributes(vault: vault, verificationMethod: scaType.rawValue)
            )
        }
    }
}
