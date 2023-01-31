import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct GetOrderInfoResponse: Decodable {

    let id, status, intent: String
    let purchaseUnits: [PurchaseUnit]?
    let paymentSource: PaymentSource?
    let links: [Link]?
}
