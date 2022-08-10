import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPalNativeCheckout

class PayPalClient_Tests: XCTestCase {

    private class MockPayPalDelegate: PayPalDelegate {

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

        var shippingChange: ShippingChange?
        var capturedResult: Approval?
        var capturedError: CoreSDKError?
        var paypalDidCancel = false

        func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
            capturedError = error
        }

        func paypalDidCancel(_ payPalClient: PayPalClient) {
            paypalDidCancel = true
        }
    }

    let config = CoreConfig(clientID: "testClientID", accessToken: "testAccessToken", environment: .sandbox)
    let nxoConfig = CheckoutConfig(
        clientID: "testClientID",
        createOrder: nil,
        onApprove: nil,
        onShippingChange: nil,
        onCancel: nil,
        onError: nil,
        environment: .sandbox
    )

    lazy var mockCheckout = MockCheckout(nxoConfig: nxoConfig)
    lazy var payPalClient = PayPalClient(config: config, checkoutFlow: mockCheckout)

    // todo: check for approval result instead of cancel
    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate

        let orderID = "orderID"

        let mockPaypalDelegate = MockPayPalDelegate()
        payPalClient.start(presentingViewController: nil, orderID: orderID, deleagate: mockPaypalDelegate)
        mockCheckout.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellation() {
        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate
        let orderID = "orderID"
        let mockPaypalDelegate = MockPayPalDelegate()
        payPalClient.start(presentingViewController: nil, orderID: orderID, deleagate: mockPaypalDelegate)
        mockCheckout.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }

    // todo: check for error case instead of cancel
    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() {

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate
        let orderID = "orderID"
        let mockPaypalDelegate = MockPayPalDelegate()
        payPalClient.start(presentingViewController: nil, orderID: orderID, deleagate: mockPaypalDelegate)
        mockCheckout.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }

    func testInit_setsPayPalCheckoutWith_returnsPayPalClient() {
        let payPalClientPublic = PayPalClient(config: config)

        XCTAssertEqual(payPalClientPublic.config.clientID, payPalClient.config.clientID)
    }
}
