import Foundation


/// Initialize a card object
/// - Parameters:
///   - number: The card number
///   - expiry: The card's expiration date
///   - securityCode: The card's security code (CVV, CVC, CVN, CVE, or CID)
public struct Card: Encodable {

    public var number: String
    public var expirationMonth: String
    public var expirationYear: String
    public var securityCode: String

    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
    }

    public var expiry: String {
        return "\(expirationYear)-\(expirationMonth)"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(expiry, forKey: .expiry)
        try container.encode(securityCode, forKey: .securityCode)
    }
}
