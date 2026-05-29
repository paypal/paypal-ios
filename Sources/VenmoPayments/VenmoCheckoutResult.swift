import Foundation

/// The result of a Venmo checkout flow.
public struct VenmoCheckoutResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// The Payer ID (or user id) associated with the transaction.
    public let payerID: String
}
