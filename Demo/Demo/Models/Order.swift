struct Order: Codable, Equatable {

    enum OrderCodingKeys: String, CodingKey {
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

    init(id: String, status: String, paymentSource: PaymentSource? = nil) {
        self.id = id
        self.status = status
        self.paymentSource = paymentSource
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OrderCodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.status = try container.decode(String.self, forKey: .status)
        self.paymentSource = try container.decodeIfPresent(PaymentSource.self, forKey: .paymentSource)
    }

    enum CardCodingKeys: String, CodingKey {
        case lastDigits = "last_digits"
        case brand
        case attributes
    }

    struct Card: Codable, Equatable {

        let lastDigits: String?
        let brand: String?
        let attributes: Attributes?

        init(lastDigits: String? = nil, brand: String? = nil, attributes: Attributes? = nil) {
            self.lastDigits = lastDigits
            self.brand = brand
            self.attributes = attributes
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CardCodingKeys.self)

            self.lastDigits = try container.decode(String.self, forKey: .lastDigits)
            self.brand = try container.decode(String.self, forKey: .brand)
            self.attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes)
        }
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
