import PayPalCheckout
@testable import CorePayments
@testable import PayPalNativePayments

class MockPayPalDelegate: PayPalNativeCheckoutDelegate {

    var shippingChange: ShippingChange?
    var capturedResult: PayPalNativeCheckoutResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false
    var paypalDidStart = false

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        capturedResult = result
    }

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalNativeCheckoutClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
        self.shippingChange = shippingChange
    }

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func paypalDidCancel(_ payPalClient: PayPalNativeCheckoutClient) {
        paypalDidCancel = true
    }

    func paypalWillStart(_ payPalClient: PayPalNativeCheckoutClient) {
        paypalDidStart = true
    }
}
