import Foundation
#if canImport(CorePayments)
import CorePayments
#endif
import PayPalCheckout

/// A required delegate to handle events from `PayPalNativeCheckoutClient.start()`
public protocol PayPalNativeCheckoutDelegate: AnyObject {

    /// Notify that the PayPal flow finished with a successful result
    /// - Parameters:
    ///   - didFinishWithResult: the successful result from the flow
    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult)
    
    /// Notify that an error occurred in the PayPal flow
    /// - Parameters:
    ///   - didFinishWithError: the error returned by the PayPal flow
    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError)

    /// Notify that the PayPal flow has been cancelled
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalDidCancel(_ payPalClient: PayPalNativeCheckoutClient)

    /// Notify that the PayPal paysheet is about to appear
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalWillStart(_ payPalClient: PayPalNativeCheckoutClient)
}

/// An optional delegate to receive notifcations if the user changes their shipping information.
public protocol PayPalNativeShippingDelegate: AnyObject {
    
    ///  Notify when the users selected shipping address changes
    /// - Parameters:
    ///   - payPalClient: the PayPalClient associated with delegate
    ///   - shippingAddress: the user's most recently selected shipping address
    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didShippingAddressChange shippingAddress: PayPalNativeShippingAddress)
    
    /// Notify when the users selected shipping method changes
    /// - Parameters:
    ///   - payPalClient: the PayPalClient associated with delegate
    ///   - shippingMethod: the user's most recently selected shipping method
    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didShippingMethodChange: PayPalNativeShippingMethod)
}
