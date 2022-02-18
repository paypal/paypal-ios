import PayPal
import PaymentsCore

class MockPayPalDelegate: PayPalDelegate {

    var capturedResult: PayPalResult?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false

    func paypal(_ paypalClient: PayPalClient, didFinishWithResult result: PayPalResult) {
        capturedResult = result
    }

    func paypal(_ paypalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func paypalDidCancel(_ paypalClient: PayPalClient) {
        paypalDidCancel = true
    }
}
