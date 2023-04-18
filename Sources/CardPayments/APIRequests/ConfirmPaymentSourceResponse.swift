import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct ConfirmPaymentSourceResponse: Decodable {
    
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}

struct Link: Decodable {

    let href: String?
    let rel, method: String?
}
