import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// tool used:  https://app.quicktype.io/#l=swift
struct GetOrderInfoResponse: Decodable {

    let id, status, intent: String
    let purchaseUnits: [PurchaseUnit]?
    let paymentSource: PaymentSource?
    let links: [Link]?
}
