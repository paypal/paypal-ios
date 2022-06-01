// swiftlint:disable space_after_main_type

struct CreateOrderParams: Codable {
    let intent: String
    let purchaseUnits: [PurchaseUnit]
    let applicationContext: ApplicationContext
}

struct PurchaseUnit: Codable {
    let amount: Amount
}

struct Amount: Codable {
    let currencyCode: String
    let value: String
}

struct ApplicationContext: Codable {
    let returnUrl = "com.paypal.android.demo://example.com/returnUrl"
    let cancelUrl = "com.paypal.android.demo://example.com/cancelUrl"
}
