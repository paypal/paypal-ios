import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPalNativeCheckout
@testable import TestShared

class PayPalClient_Tests: XCTestCase {

    private class MockPayPalDelegate: PayPalDelegate {

        var capturedResult: PayPalResult?
        var capturedError: CoreSDKError?
        var paypalDidCancel = false

        func paypal(_ payPalClient: PayPalClient, didFinishWithResult result: PayPalResult) {
            capturedResult = result
        }

        func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
            capturedError = error
        }

        func paypalDidCancel(_ payPalClient: PayPalClient) {
            paypalDidCancel = true
        }
    }

    let config = CoreConfig(accessToken: "testAccessToken", environment: .sandbox)

    lazy var payPalClient = PayPalClient(
        config: config,
        checkoutFlow: MockCheckout.self,
        apiClient: MockAPIClient(coreConfig: config)
    )

    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {
        let request = PayPalRequest(orderID: "1234")
        let approval = MockApproval(intent: "intent", payerID: "payerID", ecToken: request.orderID)
        // swiftlint: enable force_unwrapping

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate

        let expectation = XCTestExpectation(description: "returnsPayPalResult")
        await payPalClient.start(request: request)

        DispatchQueue.main.async {
            MockCheckout.triggerApproval(approval: approval)

            let approvalResult = delegate.capturedResult
            XCTAssertEqual(approvalResult?.orderID, approval.ecToken)
            XCTAssertEqual(approvalResult?.payerID, approval.payerID)
            expectation.fulfill()
        }
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancelationError() async {
        let request = PayPalRequest(orderID: "1234")

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate

        let expectation = XCTestExpectation(description: "returnsCancelationError")
        await payPalClient.start(request: request)

        DispatchQueue.main.async {
            MockCheckout.triggerCancel()
            XCTAssertTrue(delegate.paypalDidCancel)

            expectation.fulfill()
        }
    }

    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() async {
        let request = PayPalRequest(orderID: "1234")
        let error = MockPayPalError(reason: "error reason", error: NSError())

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate

        let expectation = XCTestExpectation(description: "returnsCancelationError")
        await payPalClient.start(request: request)

        DispatchQueue.main.async {
            MockCheckout.triggerError(error: error)

            let sdkError = delegate.capturedError
            XCTAssertEqual(sdkError?.code, PayPalError.Code.nativeCheckoutSDKError.rawValue)
            XCTAssertEqual(sdkError?.domain, PayPalError.domain)
            XCTAssertEqual(sdkError?.errorDescription, error.reason)

            expectation.fulfill()
        }
    }

    func testInit_setsConfigPropertiesOnNativeSDKCheckoutConfig() {
        // Need to assert that `Checkout.config` has been set
        // This is currently not exposed by the NXO SDK, so we cannot tell
        // when the NXO SDK has a config object already set on it
    }
}
