#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// The result of a PayPal checkout experience
public enum PayPalCheckoutResult {

    /// The order has been successfully approved by the buyer
    case success(result: PayPalResult)

    /// An error has occurred during the checkout experience
    case failure(error: CoreSDKError)

    /// The buyer has canceled the checkout experience
    case cancellation
}
