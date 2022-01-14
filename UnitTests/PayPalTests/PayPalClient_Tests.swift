import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)

    lazy var paypalClient = PayPalClient(
        config: config,
        returnURL: "return://url",
        checkoutFlow: MockCheckout.self
    )

    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() {
        let orderID = "1234"
        let approval = MockApproval(intent: "intent", payerID: "payerID", ecToken: orderID)

        paypalClient.start(orderID: orderID, presentingViewController: nil) { result in
            switch result {
            case .success(let approvalResult):
                XCTAssertEqual(approvalResult.orderID, approval.ecToken)
                XCTAssertEqual(approvalResult.payerID, approval.payerID)
            case .failure:
                XCTFail()
            case .cancellation:
                XCTFail()
            }
        }

        MockCheckout.triggerApproval(approval: approval)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {
        paypalClient.start(orderID: "1234", presentingViewController: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTFail()
            case .cancellation:
                MockCheckout.triggerCancel()
            }
        }
    }

    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() {
        let error = MockPayPalError(reason: "error reason", error: NSError())

        paypalClient.start(orderID: "1234", presentingViewController: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let sdkError):
                XCTAssertEqual(sdkError.code, PayPalError.Code.nativeCheckoutSDKError.rawValue)
                XCTAssertEqual(sdkError.domain, PayPalError.domain)
                XCTAssertEqual(sdkError.errorDescription, error.reason)
            case .cancellation:
                XCTFail()
            }
        }

        MockCheckout.triggerError(error: error)
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
