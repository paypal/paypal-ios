import PayPalCheckout
@testable import PaymentsCore
@testable import PayPalNativeCheckout

class MockPayPalDelegate: PayPalDelegate {

    var shippingChange: ShippingChange?
    var capturedResult: Approval?
    var capturedError: CoreSDKError?
    var paypalDidCancel = false
    var paypalDidStart = false

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
        capturedResult = approvalResult
    }

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
        self.shippingChange = shippingChange
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        capturedError = error
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        paypalDidCancel = true
    }

    func paypalWillStart(_ payPalClient: PayPalClient) {
        paypalDidStart = true
    }
}
