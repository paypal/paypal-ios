import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal delegate to handle events from PayPalClient
public protocol PayPalDelegate: AnyObject {

    /// Notify that the PayPal flow finished with a successful result
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func paypal(client paypalClient: PayPalClient, didFinishWithResult result: PayPalResult)

    /// Notify that an error occurred in the PayPal flow
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithError: the error returned by the paypal flow
    func paypal(client paypalClient: PayPalClient, didFinishWithError error: PayPalSDKError)

    /// Notify that the PayPal flow has been cancelled
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalDidCancel(client paypalClient: PayPalClient)
}
