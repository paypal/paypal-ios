import Foundation

public struct Card: Codable {

    enum CodingKeys: String, CodingKey {
        case number
        case expirationDate = "expiry"
        case securityCode = "security_code"
    }

    public var number: String
    public var expirationDate: ExpirationDate
    public var securityCode: String

    /// Initialize a card object
    /// - Parameters:
    ///   - number: The card number
    ///   - expiry: The card's expiration date
    ///   - securityCode: The card's security code (CVV, CVC, CVN, CVE, or CID)
    public init(number: String, expirationDate: ExpirationDate, securityCode: String) {
        self.number = number
        self.expirationDate = expirationDate
        self.securityCode = securityCode
    }
}
