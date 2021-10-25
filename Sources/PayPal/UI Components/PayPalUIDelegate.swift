#if canImport(PaymentsCore)
import PaymentsCore
#endif

public protocol PayPalUI: AnyObject {
    var delegate: PayPalUIDelegate? { get set }
}

/// Methods for managing approval, error and cancellation from PayPal UI components
public protocol PayPalUIDelegate: AnyObject {
    /// Invoked when a transaction is approved by the user and ready for authorization or capture by the merchant
    func paypal(_ paypal: PayPalUI, didApproveWith data: PayPalResult)
    /// Invoked when the SDK encounters an unrecoverable error
    func paypal(_ paypal: PayPalUI, didReceiveError error: PayPalSDKError)
    /// Invoked when the checkout experience has been canceled
    func paypalDidCancel(_ paypal: PayPalUI)
}
