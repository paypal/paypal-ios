import Foundation

public struct ExpirationDate: Codable {

    var expiryString: String

    /// Initialize a card expiry object
    /// - Parameters:
    ///   - month: The card expiration month (1 to 12)
    ///   - year: The card expiration year in 4-digit format, `YYYY`
    public init(month: Int, year: Int) {
        let isSingleDigit = (1...9).contains(month)
        let monthString = isSingleDigit ? "0\(month)" : "\(month)"
        expiryString = "\(year)-\(monthString)"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        expiryString = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(expiryString)
    }
}
