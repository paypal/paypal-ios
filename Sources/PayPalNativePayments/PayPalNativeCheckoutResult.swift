import Foundation

@available(*, deprecated, message: "PayPalNativePayments Module is deprecated, use PayPalWebPayments Module instead")
/// The result of a PayPal native payment flow.
public struct PayPalNativeCheckoutResult {
    
    /// The order ID associated with the transaction.
    public let orderID: String

    /// The Payer ID (or user ID) associated with the transaction.
    public let payerID: String
}
