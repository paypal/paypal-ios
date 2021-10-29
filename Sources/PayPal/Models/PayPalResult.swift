#if canImport(PayPalCheckout)
@_implementationOnly import PayPalCheckout
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

    init(approvalData: ApprovalData) {
        orderID = approvalData.ecToken
        intent = approvalData.intent
        payerID = approvalData.payerID
    }
}
