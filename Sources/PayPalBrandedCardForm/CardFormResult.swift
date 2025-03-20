import Foundation

/// Used to configure options for approving a PayPal web order
public struct CardFormResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// The Payer ID (or user id) associated with the transaction.
    public let payerID: String
}
