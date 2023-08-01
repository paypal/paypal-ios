import Foundation

struct SetUpTokenResponse: Decodable {
    
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}
