import XCTest
import AuthenticationServices
@testable import PaymentsCore
@testable import PayPal

// TODO: test delegates

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)
    let context = MockViewController()

    lazy var paypalClient = PayPalClient(config: config)

    func testStart_whenInvalidBaseURLIsPassed_returnsPayPalURLError() {
        let request = PayPalRequest(orderID: "1234")
        let mockPayPalClient = MockPayPalClient(config: config)
        mockPayPalClient.cannedURLString = "https://invalid-url"

        mockPayPalClient.start(request: request, context: context) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalClientError.domain)
                XCTAssertEqual(error.code, PayPalClientError.Code.payPalURLError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Error constructing URL for PayPal request.")
            }
        }
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalClientError.Code.webSessionError.rawValue,
            domain: PayPalClientError.domain,
            errorDescription: "Mock web session error description."
        )

        paypalClient.start(
            request: request,
            context: context,
            webAuthenticationSession: mockWebAuthenticationSession
        ) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalClientError.domain)
                XCTAssertEqual(error.code, PayPalClientError.Code.webSessionError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            }
        }
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")

        paypalClient.start(
            request: request,
            context: context,
            webAuthenticationSession: mockWebAuthenticationSession
        ) { result in
            switch result {
            case .success:
                XCTFail()
            case.failure(let error):
                XCTAssertEqual(error.domain, PayPalClientError.domain)
                XCTAssertEqual(error.code, PayPalClientError.Code.malformedResultError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Result did not contain the expected data.")
            }
        }
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")

        paypalClient.start(
            request: request,
            context: context,
            webAuthenticationSession: mockWebAuthenticationSession
        ) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(result.orderID, "1234")
                XCTAssertEqual(result.payerID, "98765")
            case.failure:
                XCTFail()
            }
        }
    }

    func testpayPalCheckoutReturnURL_returnsCorrectURL() {
        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234")!
        let checkoutURL = paypalClient.payPalCheckoutReturnURL(payPalCheckoutURL: url)

        XCTAssertEqual(
            checkoutURL,
            URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234&redirect_uri=com.apple.dt.xctest.tool://x-callback-url/paypal-sdk/paypal-checkout&native_xo=1")
        )
    }
}
