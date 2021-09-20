typealias PurchaseUnit = CreateOrderParams.PurchaseUnit
typealias Amount = CreateOrderParams.PurchaseUnit.Amount

struct CreateOrderParams: Codable {
    let intent: String
    let purchaseUnits: [PurchaseUnit]

    struct PurchaseUnit: Codable {
        let amount: Amount

        struct Amount: Codable {
            let currencyCode: String
            let value: String
        }
    }
}
