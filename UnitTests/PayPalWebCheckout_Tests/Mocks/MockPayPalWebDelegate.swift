import PaymentsCore
import PayPalWebCheckout

class MockPayPalWebDelegate: PayPalWebDelegate {

    var capturedResult: PayPalWebResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebResult) {
        capturedResult = result
    }

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func paypalDidCancel(_ paypalClient: PayPalWebCheckoutClient) {
        paypalDidCancel = true
    }
}
