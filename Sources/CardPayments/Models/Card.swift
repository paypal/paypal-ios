import Foundation

/// Represents raw credit or debit card data provided by the customer.
public struct Card: Encodable {

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

    /// This is exposed for convenience in copying card contents to UpdateSetupTokenQuery
    /// The expiration year and month, in ISO-8601 `YYYY-MM` date format.
    @_documentation(visibility: private)
    public var expiry: String {
        "\(expirationYear)-\(expirationMonth)"
    }

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
}
