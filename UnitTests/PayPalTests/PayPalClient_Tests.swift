import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

    func testPayPalClient_whenPayPalCheckoutOnCancelInvoked_completionCalledWithCancellationState() throws {
        let config = CoreConfig(clientID: "", environment: .sandbox)
        let client = PayPalClient(config: config, returnURL: "")

        let expect = expectation(description: "Expect completion with state == .cancellation")

        client.setupPayPalCheckoutConfig(orderID: "") { result in
            switch result {
            case .cancellation:
                expect.fulfill()
            default:
                XCTFail("Expect state to be cancellation")
            }
        }

        let onCancel = try XCTUnwrap(client.paypalCheckoutConfig.onCancel)
        onCancel()
        waitForExpectations(timeout: 0.2)
    }

    // TODO: Add tests for onApprove and onError
    // For now Approval/ApprovalData.init() and ErrorInfo().init() are internal in PayPalCheckout
    // so we won't be able to mock these object to call PayPalCheckout.CheckoutConfig.onApprove(Approval)/onError(ErrorInfo)
}
