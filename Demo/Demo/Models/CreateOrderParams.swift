struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
}

struct PurchaseUnit: Codable {

    let amount: Amount
    // TODO: payee information for connected_partner
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}
