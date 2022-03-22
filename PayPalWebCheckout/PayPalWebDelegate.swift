import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal delegate to handle events from PayPalClient
public protocol PayPalWebDelegate: AnyObject {

    /// Notify that the PayPal flow finished with a successful result
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebResult)

    /// Notify that an error occurred in the PayPal flow
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithError: the error returned by the PayPal flow
    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithError error: PayPalSDKError)

    /// Notify that the PayPal flow has been cancelled
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalDidCancel(_ paypalClient: PayPalWebCheckoutClient)
}
