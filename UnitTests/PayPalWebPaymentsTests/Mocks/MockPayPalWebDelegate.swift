import PaymentsCore
import PayPalWebPayments

class MockPayPalWebDelegate: PayPalWebCheckoutDelegate {

    var capturedResult: PayPalWebCheckoutResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        capturedResult = result
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        paypalDidCancel = true
    }
}
