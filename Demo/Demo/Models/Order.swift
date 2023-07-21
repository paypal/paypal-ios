struct Order: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case paymentSource = "payment_source"
    }
    
    let id: String
    let status: String
    var paymentSource: PaymentSource?
    
    struct PaymentSource: Codable {
        
        let card: Card
    }

    struct Card: Codable {
        
        let attributes: Attributes?
    }

    struct Attributes: Codable {
        
        let vault: Vault
    }

    struct Vault: Codable {
        
        let id: String
        let status: String
        let customer: Customer
    }

    struct Customer: Codable {
        
        let id: String
    }
}
