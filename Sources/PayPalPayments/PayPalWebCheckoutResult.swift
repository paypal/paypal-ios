import Foundation

/// The result of a PayPal web payment flow.
public struct PayPalWebCheckoutResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// The Payer ID (or user id) associated with the transaction.
    public let payerID: String
}
