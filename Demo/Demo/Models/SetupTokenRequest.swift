import Foundation
import CorePayments

struct SetUpTokenRequest: APIRequest {
   
    init(
        card: Card,
        customerID: String? = nil
    ) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let paymentSource = PaymentSource(card: card)
        let tokenRequestBody = SetUpTokenRequestBody(customerID: customerID, paymentSource: paymentSource)
        body = try? jsonEncoder.encode(tokenRequestBody)
    }
    
    // MARK: - APIRequest
    
    typealias ResponseType = SetUpTokenResponse
    var path: String = "/setup-tokens/"
    var method: HTTPMethod = .post
    var body: Data?
    
    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json", .acceptLanguage: "en_US"
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
