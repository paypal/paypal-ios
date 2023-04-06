struct GetOrderAmountResponse: Decodable {

    let id: String
    let purchaseUnits: [PurchaseUnit]?
}

struct PurchaseUnit: Codable {

    let amount: Amount
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}
