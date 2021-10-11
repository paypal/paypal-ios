import Foundation

/// Type of card. i.e Credit, Debit and so on.
public enum CardType: String, Codable {

    /// A credit card
    case credit = "CREDIT"

    /// A debit card
    case debit = "DEBIT"

    /// A prepaid card
    case prepaid = "PREPAID"

    /// A store card
    case store = "STORE"

    /// Card type cannot be determined
    case unknown = "UNKNOWN"
}
