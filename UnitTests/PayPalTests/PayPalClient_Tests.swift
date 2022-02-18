import XCTest
import AuthenticationServices
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)
    let context = MockViewController()

    lazy var paypalClient = PayPalClient(config: config)

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {
        let request = PayPalRequest(orderID: "1234")
        let delegate = MockPayPalDelegate()
        let mockWebAuthenticationSession = MockWebAuthenticationSession()

        paypalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        paypalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        XCTAssertTrue(delegate.paypalDidCancel)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalDelegate()

        paypalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalClientError.Code.webSessionError.rawValue,
            domain: PayPalClientError.domain,
            errorDescription: "Mock web session error description."
        )

        paypalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalClientError.domain)
        XCTAssertEqual(error?.code, PayPalClientError.Code.webSessionError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Mock web session error description.")
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalDelegate()

        paypalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        paypalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalClientError.domain)
        XCTAssertEqual(error?.code, PayPalClientError.Code.malformedResultError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Result did not contain the expected data.")
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalDelegate()

        paypalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        paypalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let result = delegate.capturedResult

        XCTAssertEqual(result?.orderID, "1234")
        XCTAssertEqual(result?.payerID, "98765")
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
