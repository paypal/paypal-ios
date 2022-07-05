import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct GetOrderInfoResponse: Decodable {

    let id, status, intent: String
    let purchaseUnits: [PurchaseUnit]?
    let paymentSource: PaymentSource?
    let links: [Link]?
}
