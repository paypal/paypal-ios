import XCTest
import AuthenticationServices
@testable import PaymentsCore
@testable import PayPalWebCheckout
@testable import TestShared

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", accessToken: "testAccessToken", environment: .sandbox)
    let context = MockViewController()

    lazy var payPalClient = PayPalWebCheckoutClient(config: config)

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let delegate = MockPayPalWebDelegate()
        let mockWebAuthenticationSession = MockWebAuthenticationSession()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        payPalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        XCTAssertTrue(delegate.paypalDidCancel)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: "Mock web session error description."
        )

        payPalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalWebCheckoutClientError.domain)
        XCTAssertEqual(error?.code, PayPalWebCheckoutClientError.Code.webSessionError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Mock web session error description.")
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        payPalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalWebCheckoutClientError.domain)
        XCTAssertEqual(error?.code, PayPalWebCheckoutClientError.Code.malformedResultError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Result did not contain the expected data.")
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        payPalClient.start(request: request, context: context, webAuthenticationSession: mockWebAuthenticationSession)

        let result = delegate.capturedResult

        XCTAssertEqual(result?.orderID, "1234")
        XCTAssertEqual(result?.payerID, "98765")
    }

    func testpayPalCheckoutReturnURL_returnsCorrectURL() {
        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234")!
        let checkoutURL = payPalClient.payPalCheckoutReturnURL(payPalCheckoutURL: url)

        XCTAssertEqual(
            checkoutURL,
            URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234&redirect_uri=com.apple.dt.xctest.tool://x-callback-url/paypal-sdk/paypal-checkout&native_xo=1")
        )
    }
}
