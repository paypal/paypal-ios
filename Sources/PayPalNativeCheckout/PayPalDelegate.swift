import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif
import PayPalCheckout

/// PayPal delegate to handle events from PayPalClient
public protocol PayPalDelegate: AnyObject {

    /// Notify that the PayPal flow finished with a successful result
    /// - Parameters:
    ///   - didFinishWithResult: the successful result from the flow
    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: PayPalCheckout.Approval)

    /// Notify that an error occurred in the PayPal flow
    /// - Parameters:
    ///   - didFinishWithError: the error returned by the PayPal flow
    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError)

    /// Notify that the PayPal flow has been cancelled
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalDidCancel(_ payPalClient: PayPalClient)

    /// Notify that the PayPal flow is about to start
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    func paypalDidStart(_ payPalClient: PayPalClient)

    /// Notify when a shipping method and/or address has changed
    /// - Parameters:
    ///   - client: the PayPalClient associated with delegate
    ///   - shippingChange: what change was produced in shipping
    ///   - shippingChangeAction: actions to perform for the change in shipping
    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    )
}
