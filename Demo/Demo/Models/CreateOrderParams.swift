import Card
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
    var customId: String?
    var description: String?
    var items: [Item]?
    var payee: Payee?
    var referenceId: String?
    var shipping: Shipping?
    var softDescriptor: String?
}

struct Breakdown: Codable {

    var discount: AmountBreakdown?
    var handling: AmountBreakdown?
    var itemTotal: AmountBreakdown?
    var shipping: AmountBreakdown?
    var shippingDiscount: AmountBreakdown?
    var taxTotal: AmountBreakdown?
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
    var breakdown: Breakdown?
}

struct AmountBreakdown: Codable {

    let currencyCode: String
    let value: String
}

struct Item: Codable {

    var category: String?
    var description: String?
    var name: String?
    var quantity: String
    var sku: String?
    var tax: Amount?
    var unitAmount: Amount?
}

struct Payee: Codable {

    var emailAddress: String?
    var merchantId: String?
}

struct Shipping: Codable {

    var address: Address?
}
