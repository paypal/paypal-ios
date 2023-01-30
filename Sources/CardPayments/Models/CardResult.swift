import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// The result of a card payment flow.
public struct CardResult {

    /// The order ID associated with the transaction
    public let orderID: String

    /// The order status
    public let status: String

    /// The payment source
    public let paymentSource: PaymentSource?
}
