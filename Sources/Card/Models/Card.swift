import Foundation

public struct Card: Encodable {

    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
        case cardholderName = "name"
        case billingAddress
    }

    /// The primary account number (PAN) for the payment card.
    public var number: String

    /// The card expiration month in `MM` format
    public var expirationMonth: String

    /// The card expiration year in `YYYY` format
    public var expirationYear: String

    /// The three- or four-digit security code of the card. Also known as the CVV, CVC, CVN, CVE, or CID.
    public var securityCode: String

    /// The card holder's name as it appears on the card.
    public var cardholderName: String?

    /// The billing address
    public var billingAddress: Address?

    /// The expiration year and month, in ISO-8601 `YYYY-MM` date format.
    public var expiry: String {
        "\(expirationYear)-\(expirationMonth)"
    }

    public init(
        number: String,
        expirationMonth: String,
        expirationYear: String,
        securityCode: String,
        cardHolderName: String? = nil,
        billingAddress: Address? = nil
    ) {
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.cardholderName = cardHolderName
        self.billingAddress = billingAddress
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(expiry, forKey: .expiry)
        try container.encode(securityCode, forKey: .securityCode)
        try container.encode(cardholderName, forKey: .cardholderName)
        try container.encode(billingAddress, forKey: .billingAddress)
    }
}
