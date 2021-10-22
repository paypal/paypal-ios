import PaymentsCore
import PayPalCheckout

// TODO: add documentation
extension ErrorInfo {
    func toPayPalSDKError() -> PayPalSDKError {
        PayPalSDKError(code: 1, domain: "PayPalCheckoutErrorDomain", errorDescription: reason)
    }
}
