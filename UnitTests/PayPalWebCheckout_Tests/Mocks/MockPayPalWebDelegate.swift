import PaymentsCore
import PayPalWebCheckout

class MockPayPalWebDelegate: PayPalWebCheckoutDelegate {

    var capturedResult: PayPalWebCheckoutResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        capturedResult = result
    }

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func paypalDidCancel(_ paypalClient: PayPalWebCheckoutClient) {
        paypalDidCancel = true
    }
}
