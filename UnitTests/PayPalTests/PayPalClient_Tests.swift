import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

//    func testPayPalClientStart_whenNoPresentingViewControllerProvidedOrFound_completionCalledWithErrorResult() {
//        let config = CoreConfig(clientID: "", environment: .sandbox)
//        let client = PayPalClient(config: config, returnURL: "")
//
//        let expect = expectation(description: "Expect completion with error result")
//
//        client.start(orderID: "", presentingViewController: nil) { result in
//            switch result {
//            case .failure(let error):
//                // TODO: Update errors in PayPalCheckout with more detailed description/reason
//                // We should expect a failure since we don't provide presentingViewController and PayPalCheckout won't be able to find a top most ViewController in unit test
//                XCTAssertEqual(error.code, PayPalError.Code.payPalCheckoutError.rawValue)
//                XCTAssertEqual(error.domain, PayPalError.domain)
//                expect.fulfill()
//            default:
//                XCTFail("Expect completion with error result")
//            }
//        }
//
//        waitForExpectations(timeout: 0.2)
//    }

    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() {

    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {

    }

    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() {
        
    }

    func testInit_setsConfigPropertiesOnNativeSDKCheckoutConfig() {

    }

}
