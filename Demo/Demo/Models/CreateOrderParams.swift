struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var paymentSource: PaymentSource?
    var applicationContext: ApplicationContext?
}

struct PaymentSource: Codable {

    var paypal: PayPalPaymentSource?
}

struct PayPalPaymentSource: Codable {

    let attributes: Attributes
}

struct Attributes: Codable {

    let vault: Vault
}

struct Vault: Codable {

    let confirmPaymentToken: String
    let usageType: String
}

struct PurchaseUnit: Codable {

    let amount: Amount
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}
