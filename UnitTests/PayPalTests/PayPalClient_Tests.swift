import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

    private class MockPayPalDelegate: PayPalDelegate {

        var capturedResult: PayPalResult?
        var capturedError: PayPalSDKError?
        var paypalDidCancel = false

        func paypal(_ paypalClient: PayPalClient, didFinishWithResult result: PayPalResult) {
            capturedResult = result
        }

        func paypal(_ paypalClient: PayPalClient, didFinishWithError error: PayPalSDKError) {
            capturedError = error
        }

        func paypalDidCancel(_ paypalClient: PayPalClient) {
            paypalDidCancel = true
        }
    }

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)

    lazy var paypalClient = PayPalClient(
        config: config,
        returnURL: "return://url",
        checkoutFlow: MockCheckout.self
    )

    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {
        let request = PayPalRequest(orderID: "1234")
        let approval = MockApproval(intent: "intent", payerID: "payerID", ecToken: request.orderID)

        let delegate = MockPayPalDelegate()
        paypalClient.delegate = delegate

        paypalClient.start(request: request, presentingViewController: nil)
        MockCheckout.triggerApproval(approval: approval)

        let approvalResult = delegate.capturedResult
        XCTAssertEqual(approvalResult?.orderID, approval.ecToken)
        XCTAssertEqual(approvalResult?.payerID, approval.payerID)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {
        let request = PayPalRequest(orderID: "1234")

        let delegate = MockPayPalDelegate()
        paypalClient.delegate = delegate

        paypalClient.start(request: request, presentingViewController: nil)
        MockCheckout.triggerCancel()

        XCTAssertTrue(delegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() {
        let request = PayPalRequest(orderID: "1234")
        let error = MockPayPalError(reason: "error reason", error: NSError())

        let delegate = MockPayPalDelegate()
        paypalClient.delegate = delegate

        paypalClient.start(request: request, presentingViewController: nil)
        MockCheckout.triggerError(error: error)

        let sdkError = delegate.capturedError
        XCTAssertEqual(sdkError?.code, PayPalError.Code.nativeCheckoutSDKError.rawValue)
        XCTAssertEqual(sdkError?.domain, PayPalError.domain)
        XCTAssertEqual(sdkError?.errorDescription, error.reason)
    }

    func testInit_setsPayPalCheckoutWith_returnsPayPalClient() {
        let payPalClientPublic = PayPalClient(config: config, returnURL: "return://url")

        XCTAssertEqual(payPalClientPublic.config.clientID, paypalClient.config.clientID)
        XCTAssertEqual(payPalClientPublic.returnURL, paypalClient.returnURL)
    }

    func testInit_setsConfigPropertiesOnNativeSDKCheckoutConfig() {
        // Need to assert that `Checkout.config` has been set
        // This is currently not exposed by the NXO SDK, so we cannot tell
        // when the NXO SDK has a config object already set on it
    }
}
