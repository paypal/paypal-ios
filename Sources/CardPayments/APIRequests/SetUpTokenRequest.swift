import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct SetUpTokenRequest: APIRequest {
   
    private let base64EncodedCredentials: String
    var jsonEncoder: JSONEncoder
    
    init(
        clientID: String,
        vaultRequest: VaultRequest,
        encoder: JSONEncoder = JSONEncoder() // exposed for test injection
    ) throws {
        self.jsonEncoder = encoder
        self.base64EncodedCredentials = Data(clientID.appending(":").utf8).base64EncodedString()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let customerID = vaultRequest.customerID
        let card = vaultRequest.card
        let paymentSource = PaymentSource(card: card)
        let tokenRequestBody = SetUpTokenRequestBody(customerID: customerID, paymentSource: paymentSource)
        do {
            body = try jsonEncoder.encode(tokenRequestBody)
        } catch {
            throw CardClientError.encodingError
        }
    }
    
    // MARK: - APIRequest
    
    typealias ResponseType = SetUpTokenResponse
    var path: String = "/v3/vault/setup-tokens/"
    var method: HTTPMethod = .post
    var body: Data?
    
    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Basic \(base64EncodedCredentials)"
        ]
    }
    
    private struct SetUpTokenRequestBody: Encodable {
        
        var customer: Customer?
        var paymentSource: PaymentSource
        
        init(customerID: String?, paymentSource: PaymentSource) {
            if let customerID {
                self.customer = Customer(id: customerID)
            }
            self.paymentSource = paymentSource
        }
    }
    
    private struct Customer: Encodable {
        
        let id: String
    }
    
    private struct EncodedCard: Encodable {
        
        let number: String
        let securityCode: String
        let billingAddress: Address?
        let name: String?
        let expiry: String
        let verificationMethod: String = "SCA_WHEN_REQUIRED"
        let experienceContext: ExperienceContext
    }
    
    private struct ExperienceContext: Encodable {
        
        let returnUrl: String = "https://example.com/returnUrl"
        let cancelUrl: String = "https://example.com/returnUrl"
    }
    
    private struct PaymentSource: Encodable {
        
        let card: EncodedCard
        
        init(card: Card) {
            self.card = EncodedCard(
                number: card.number,
                securityCode: card.securityCode,
                billingAddress: card.billingAddress,
                name: card.cardholderName,
                expiry: "\(card.expirationYear)-\(card.expirationMonth)",
                experienceContext: ExperienceContext()
                )
        }
    }
}
