import Foundation
#if canImport(CorePayments)
import CorePayments
#endif
import PayPalCheckout

/// PayPal delegate to handle events from PayPalClient
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

    /// Notify when a shipping method and/or address has changed
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - shippingChange: what change was produced in shipping
    ///   - shippingChangeAction: actions to perform for the change in shipping
    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalNativeCheckoutClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    )
    
//    func paypalDidShippingInfoChange(
//        _ payPalClient: PayPalNativeCheckoutClient,
//        address: Address?,
//        shippingMethod: ShippingMethod?,
//    )
    
    func onShippingAddressChanged(_ payPalClient: PayPalNativeCheckoutClient, shippingAddress: PayPalNativeShippingAddress)
    
    func onShippingMethodChanged(_ payPalClient: PayPalNativeCheckoutClient, shippingMethods: [PayPalNativeShippingMethod])
}
