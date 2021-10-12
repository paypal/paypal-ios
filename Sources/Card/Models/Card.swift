import Foundation

public struct Card: Encodable {

    /// The primary account number (PAN) for the payment card.
    public var number: String

    /// The card expiration month
    public var expirationMonth: String

    /// The card expiration year
    public var expirationYear: String

    /// The three- or four-digit security code of the card. Also known as the CVV, CVC, CVN, CVE, or CID.
    public var securityCode: String

    /// The card holder's name as it appears on the card.
    public var name: String?

    /// The portable international postal address. Maps to [AddressValidationMetadata](https://github.com/googlei18n/libaddressinput/wiki/AddressValidationMetadata) and HTML 5.1 [Autofilling form controls: the autocomplete attribute](https://www.w3.org/TR/html51/sec-forms.html#autofilling-form-controls-the-autocomplete-attribute).
    public var billingAddress: Address?

    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
        case name
        case billingAddress
    }

    /// The expiration year and month, in ISO-8601 `YYYY-MM` date format.
    public var expiry: String {
        "\(expirationYear)-\(expirationMonth)"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(expiry, forKey: .expiry)
        try container.encode(securityCode, forKey: .securityCode)
        try container.encode(name, forKey: .name)
        try container.encode(billingAddress, forKey: .billingAddress)
    }
}
