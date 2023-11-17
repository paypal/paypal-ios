struct Order: Codable, Equatable {
    
    let id: String
    let status: String
    let payerID: String?
    let paymentSource: PaymentSource?

    struct PaymentSource: Codable, Equatable {
        
        let card: Card?
        let paypal: PayPal?
    }

    init(id: String, status: String, paymentSource: PaymentSource? = nil, payerID: String? = nil) {
        self.id = id
        self.status = status
        self.paymentSource = paymentSource
        self.payerID = payerID
    }

    struct Card: Codable, Equatable {

        let lastDigits: String?
        let brand: String?
        let attributes: Attributes?
    }

    struct PayPal: Codable, Equatable {

        let emailAddress: String
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
