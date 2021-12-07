import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// The result of a card payment flow.
public struct CardOrderApproval {

    /// The order ID associated with the transaction
    public let orderID: String

    /// The last four digits of the provided card
    public let lastFourDigits: String?

    /// The card network
    /// - Examples: "VISA", "MASTERCARD"
    public let brand: String?

    /// The type of the provided card.
    /// - Examples: "DEBIT", "CREDIT"
    public let type: String?
}
