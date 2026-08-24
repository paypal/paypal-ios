import Foundation

/// The result of a Venmo checkout flow.
public struct VenmoCheckoutResult {

    /// The order ID associated with the completed transaction.
    public let orderID: String

    /// The Payer ID (or user ID) associated with the Venmo transaction.
    public let payerID: String
}
