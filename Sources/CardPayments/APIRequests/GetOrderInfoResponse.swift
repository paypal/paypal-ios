import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct GetOrderInfoResponse: Decodable {

    let id, status, intent: String
    let paymentSource: PaymentSource?
    let purchaseUnits: [PurchaseUnit]?
    let links: [Link]?
}

struct PurchaseUnit: Codable {

    let amount: Amount
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}
