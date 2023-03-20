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

struct PurchaseUnit: Codable {

    let amount: Amount
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}
