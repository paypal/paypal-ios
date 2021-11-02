#if canImport(PayPalCheckout)
@_implementationOnly import PayPalCheckout
#endif

import Foundation

/// The result of a PayPal payment flow.
public struct PayPalResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// Payer ID is also the user id associated with the transaction.
    public let payerID: String
}
