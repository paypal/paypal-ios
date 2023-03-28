import PayPalCheckout
@testable import CorePayments
@testable import PayPalNativePayments

class MockPayPalDelegate: PayPalNativeCheckoutDelegate {

    var capturedResult: PayPalNativeCheckoutResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false
    var paypalDidStart = false

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        capturedResult = result
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
