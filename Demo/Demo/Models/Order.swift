struct Order: Codable, Equatable {
    
    let id: String
    let status: String
    var paymentSource: PaymentSource?
    var links: [Link]?

    struct PaymentSource: Codable, Equatable {
        
        let card: Card?
        let paypal: PayPal?
    }

    struct Link: Codable, Equatable {

        let href: String?
        let rel, method: String?
    }

    init(id: String, status: String, paymentSource: PaymentSource? = nil) {
        self.id = id
        self.status = status
        self.paymentSource = paymentSource
    }

    struct Card: Codable, Equatable {

        let lastDigits: String?
        let brand: String?
        let attributes: Attributes?
    }

    struct PayPal: Codable, Equatable {

        let emailAddress: String?
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
