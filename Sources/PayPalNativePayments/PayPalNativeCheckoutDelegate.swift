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

/// A delegate to receive notifications if the user changes their shipping information.
///
/// This is **only required** if the order ID was created with `shipping_preferences = GET_FROM_FILE`. [See Orders V2 documentation](https://developer.paypal.com/docs/api/orders/v2/#definition-order_application_context). If the order ID was created with `shipping_preferences = NO_SHIPPING` or `SET_PROVIDED_ADDRESS`, don't implement this protocol.
public protocol PayPalNativeShippingDelegate: AnyObject {
    
    /// Notify when the users selected shipping address changes. Use `PayPalNativeShippingActions.approve`
    /// or `PayPalNativeShippingActions.reject` to approve or reject the newly selected shipping address.
    /// Optionally, if the order needs to be patched, call  `PayPalNativeShippingActions.approve` once
    /// patching has completed successfully.
    /// - Parameters:
    ///   - payPalClient: the PayPalClient associated with delegate
    ///   - shippingAddress: the user's most recently selected shipping address
    ///   - shippingActions: actions to perform after a change in shipping address
    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingAddressChange shippingAddress: PayPalNativeShippingAddress,
        withAction shippingActions: PayPalNativePaysheetActions
    )
    
    /// Notify when the users selected a different shipping method. To reflect the newly selected
    /// shipping method in the paysheet, patch the order on your server with operation `replace`, with all of the
    /// shipping methods (marking the new one as selected). You can also update the amount to reflect
    /// the new shipping cost. Once patching completes, its mandatory to call `PayPalNativeShippingActions.approve` or
    /// `PayPalNativeShippingActions.reject` to either accept or reject the changes and continue the flow.
    /// Visit https://developer.paypal.com/docs/api/orders/v2/#orders_patch for
    /// more detailed information on patching an order.
    /// - Parameters:
    ///   - payPalClient: the PayPalClient associated with delegate
    ///   - shippingMethod: the user's most recently selected shipping method
    ///   - shippingActions: actions to perform after a change in shipping method
    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingMethodChange shippingMethod: PayPalNativeShippingMethod,
        withAction shippingActions: PayPalNativePaysheetActions
    )
}
