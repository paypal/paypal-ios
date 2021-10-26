import XCTest
@testable import PaymentsCore
@testable import PayPal

final class PayPalPaysheet_Tests: XCTestCase {

    func testPayPalPaysheet_whenPayPalCheckoutOnCancelInvoked_completionCalledWithCancellationState() throws {
        let config = CoreConfig(clientID: "", environment: .sandbox)
        let paypalPaysheet = PayPalPaysheet(config: config, returnURL: "")

        let expect = expectation(description: "Expect completion with state == .cancellation")

        paypalPaysheet.setupPayPalCheckoutConfig(orderID: "") { state in
            switch state {
            case .cancellation:
                expect.fulfill()
            default:
                XCTFail("Expect state to be cancellation")
            }
        }

        let onCancel = try XCTUnwrap(paypalPaysheet.paypalCheckoutConfig.onCancel)
        onCancel()
        waitForExpectations(timeout: 0.2)
    }

    // TODO: Add tests for onApprove and onError
    // For now Approval/ApprovalData.init() and ErrorInfo().init() are internal in PayPalCheckout
    // so we won't be able to mock these object to call PayPalCheckout.CheckoutConfig.onApprove(Approval)/onError(ErrorInfo)
}
