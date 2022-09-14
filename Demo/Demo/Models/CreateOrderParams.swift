import Card
struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var applicationContext: ApplicationContext?
}

struct PurchaseUnit: Codable {

    let amount: Amount
    var items: [Item]?
    var referenceId: String?
    var shipping: Shipping?
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}

struct Item: Codable {

    var description: String?
    var name: String?
    var quantity: String
    var unitAmount: Amount?
}

struct Shipping: Codable {

    var shippingName: ShippingName
    var address: Address?
    var options: [ShippingMethod]?
}

struct ShippingName: Codable {

    var fullName: String
}

struct ShippingMethod: Codable {

    var id: String
    var label: String
    var selected: Bool
    var type: String
    var amount: Amount
}
