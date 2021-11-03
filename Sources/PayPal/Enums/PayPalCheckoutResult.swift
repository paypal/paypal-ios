#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// The result of a PayPal checkout experience
public enum PayPalCheckoutResult {

    /// The order has been successfully approved by the buyer
    case success(result: PayPalResult)

    /// An error has occurred during the checkout experience
    case failure(error: PayPalSDKError)

    /// The buyer has cancelled the checkout experience
    case cancellation
}


//Result<PayPalResult, PayPalCheckoutError>
//
//switch result {
//    .success (paypalresult)
//    .failure (error):
//        switch .cancel
//        switch .error
//}
