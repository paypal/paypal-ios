import PaymentsCore
import Foundation

// TODO: add top level documentation
public protocol PayPalInterfaceDelegate: AnyObject {
    /// Invoked when a transaction is approved by the user and ready for authorization or capture by the merchant
    func paypal(_ paypal: PayPalInterface, didApproveWith data: PayPalResult)
    /// Invoked when the SDK encounters an unrecoverable error
    func paypal(_ paypal: PayPalInterface, didReceiveError error: PayPalSDKError)
    /// Invoked when the checkout experience has been canceled
    func paypalDidCancel(_ paypal: PayPalInterface)
}
