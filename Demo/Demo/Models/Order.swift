struct Order: Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case paymentSource = "payment_source"
    }
    
    let id: String
    let status: String
    var paymentSource: PaymentSource?
    
    struct PaymentSource: Codable, Equatable {
        
        let card: Card
    }

    struct Card: Codable, Equatable {
        
        let attributes: Attributes?
    }

    struct Attributes: Codable, Equatable {
        
        let vault: Vault
    }

    struct Vault: Codable, Equatable {
        
        let id: String
        let status: String
        let customer: Customer
    }

    struct Customer: Codable, Equatable {
        
        let id: String
    }
}
