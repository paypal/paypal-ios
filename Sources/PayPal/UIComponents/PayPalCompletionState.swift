#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// The completion state of a PayPal checkout experience
public enum PayPalCheckoutState {

    /// The order has been successfully approved by the buyer
    case success(result: PayPalResult)

    /// An error has occurred during the checkout experience
    case failure(error: PayPalSDKError)

    /// The buyer has cancelled the checkout experience
    case cancellation
}
