#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

extension ApprovalData {

    /// Convert `PayPalCheckout.ApprovalData` to `PayPalResult`
    func toPayPalResult() -> PayPalResult {
        PayPalResult(orderID: ecToken, intent: intent, payerID: payerID)
    }
}
