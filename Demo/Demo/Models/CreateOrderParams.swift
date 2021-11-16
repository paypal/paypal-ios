// swiftlint:disable space_after_main_type

struct CreateOrderParams: Codable {
    let intent: String
    let purchaseUnits: [PurchaseUnit]
}

struct PurchaseUnit: Codable {
    let amount: Amount
}

struct Amount: Codable {
    let currencyCode: String
    let value: String
}
