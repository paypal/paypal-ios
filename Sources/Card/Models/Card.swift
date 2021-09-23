#if canImport(PaymentsCore)
import PaymentsCore
#endif

public struct Card: Codable {
    var number: String
    var expiry: CardExpiry
    var securityCode: String?

    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode = "security_code"
    }

    init(number: String, expiry: CardExpiry, securityCode: String? = nil) {
        self.number = number
        self.expiry = expiry
        self.securityCode = securityCode
    }
}

public struct CardExpiry: Codable {

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
