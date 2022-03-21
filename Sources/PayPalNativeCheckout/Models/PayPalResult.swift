@_implementationOnly import PayPalCheckout

import Foundation

/// The result of a PayPal payment flow.
public struct PayPalResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// The Payer ID (or user id) associated with the transaction.
    public let payerID: String
}
