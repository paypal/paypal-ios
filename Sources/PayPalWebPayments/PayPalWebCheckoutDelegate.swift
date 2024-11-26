import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// PayPal delegate to handle events from PayPalNativeCheckoutClient
@available(*, deprecated, message: "This protocol is deprecated and will be removed in version 2.0.0. Please use the new completion handler-based approach instead. For more details, visit the v2 migration guide: https://github.com/paypal/paypal-ios/")
public protocol PayPalWebCheckoutDelegate: AnyObject {

    /// Notify that the PayPal flow finished with a successful result
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult)

    /// Notify that an error occurred in the PayPal flow
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - didFinishWithError: the error returned by the PayPal flow
    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError)

    /// Notify that the PayPal flow has been cancelled
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient)
}
