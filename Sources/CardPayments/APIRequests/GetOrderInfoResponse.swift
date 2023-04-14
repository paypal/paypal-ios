import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct GetOrderInfoResponse: Decodable {

    public let id, status, intent: String
    public let paymentSource: PaymentSource?
    public let purchaseUnits: [PurchaseUnit]?
    public let links: [Link]?
}

struct PurchaseUnit: Codable {

    public let amount: Amount
}

struct Amount: Codable {

    public let currencyCode: String
    public let value: String
}

struct Link: Decodable {

    public let href: String?
    public let rel, method: String?
}
