import Foundation

/// Represents raw credit or debit card data provided by the customer.
public struct Card: Encodable {

    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
        case cardholderName = "name"
        case billingAddress
        case attributes
    }

    /// The primary account number (PAN) for the payment card.
    public var number: String

    /// The 2-digit card expiration month in `MM` format
    public var expirationMonth: String

    /// The 4-digit card expiration year in `YYYY` format
    public var expirationYear: String

    /// The three- or four-digit security code of the card. Also known as the CVV, CVC, CVN, CVE, or CID.
    public var securityCode: String

    /// Optional. The card holder's name as it appears on the card.
    public var cardholderName: String?

    /// Optional. The billing address
    public var billingAddress: Address?
    
    /// The expiration year and month, in ISO-8601 `YYYY-MM` date format.
    private var expiry: String {
        "\(expirationYear)-\(expirationMonth)"
    }

    internal var attributes: Attributes?

    public init(
        number: String,
        expirationMonth: String,
        expirationYear: String,
        securityCode: String,
        cardholderName: String? = nil,
        billingAddress: Address? = nil
    ) {
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.cardholderName = cardholderName
        self.billingAddress = billingAddress
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(expiry, forKey: .expiry)
        try container.encode(securityCode, forKey: .securityCode)
        try container.encode(cardholderName, forKey: .cardholderName)
        try container.encode(billingAddress, forKey: .billingAddress)
        try container.encode(attributes, forKey: .attributes)
    }
}

struct Attributes: Codable {

    let verification: Verification
}

struct Verification: Codable {

    let method: String
}
