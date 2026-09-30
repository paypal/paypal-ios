struct Order: Codable, Equatable, Hashable {
    
    let id: String
    let status: String
    let paymentSource: PaymentSource?

    struct PaymentSource: Codable, Equatable, Hashable {
        
        let card: Card?
        let paypal: PayPal?
    }

    init(id: String, status: String, paymentSource: PaymentSource? = nil) {
        self.id = id
        self.status = status
        self.paymentSource = paymentSource
    }

    enum CodingKeys: String, CodingKey {
        case id, status, paymentSource
    }

    /// The Live merchant returns only `id` when creating an order and only `status` when
    /// capturing or authorizing one, so neither is required to decode.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        paymentSource = try container.decodeIfPresent(PaymentSource.self, forKey: .paymentSource)
    }

    struct Card: Codable, Equatable, Hashable {

        let lastDigits: String?
        let brand: String?
        let attributes: Attributes?
    }

    struct PayPal: Codable, Equatable, Hashable {

        let emailAddress: String?
        let attributes: Attributes?
    }

    struct Attributes: Codable, Equatable, Hashable {
        
        let vault: Vault
    }

    struct Vault: Codable, Equatable, Hashable {
        
        let id: String?
        let status: String
        let customer: Customer?
    }

    struct Customer: Codable, Equatable, Hashable {
        
        let id: String
    }
}
