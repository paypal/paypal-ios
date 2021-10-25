#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

import Foundation

/// The result of a PayPal payment flow.
public struct PayPalResult {

    /// The order ID associated with the transaction.
    public let orderID: String

    /// Intent, this will be `CAPTURE` or `AUTHORIZE` if the order token was generated using the `v2/` API.
    public let intent: String

    /// Payer ID is also the user id associated with the transaction.
    public let payerID: String

    /// Return URL can be used to redirect control back to the merchant.
    public let returnURL: URL?
}
