import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalClient_Tests: XCTestCase {
    
    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockNetworkingClient: MockNetworkingClient!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        
        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }
    
    func testVault_whenSuccessUrl_ReturnsVaultToken() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let url = URL(string: "https://sandbox.paypal.com/vault")
        let expectedTokenIDResult = "fakeTokenID"
        let expectedSessionIDResult = "fakeSessionID"
        let mockVaultDelegate = MockPayPalVaultDelegate(success: {_, result in
            XCTAssertEqual(expectedTokenIDResult, result.tokenID)
            XCTAssertEqual(expectedSessionIDResult, result.approvalSessionID)
            expectation.fulfill()
        }, error: {_, _ in
            XCTFail("Invoked error() callback. Should invoke success().")
        })
        payPalClient.vaultDelegate = mockVaultDelegate
        payPalClient.vault(url: url!)

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_cancelled() {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault(url:) completed")

        let url = URL(string: "https://sandbox.paypal.com/vault")
        let mockVaultDelegate = MockPayPalVaultDelegate(success: {_, _ in
            XCTFail("Invoked success callback. Should invoke cancel().")
        }, error: {_, _ in
            XCTFail("Invoked error() callback. Should invoke success().")
        }, cancel: { _ in
            XCTAssert(true)
            expectation.fulfill()
        })
        payPalClient.vaultDelegate = mockVaultDelegate
        payPalClient.vault(url: url!)

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_returnsDefaultError() {

        let expectedError = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: PayPalWebCheckoutClientError.payPalVaultResponseError.errorDescription
        )
        mockWebAuthenticationSession.cannedErrorResponse = expectedError

        let expectation = expectation(description: "vault(url:) completed")

        let url = URL(string: "https://sandbox.paypal.com/vault")
        let mockVaultDelegate = MockPayPalVaultDelegate(success: {_, _ in
            XCTFail("Invoked success callback. Should invoke error().")
        }, error: {_, vaultError in
            XCTAssertEqual(vaultError.code, expectedError.code)
            expectation.fulfill()
        }, cancel: { _ in
            XCTFail("Invoked cancel callback. Should invoke error().")
        })
        payPalClient.vaultDelegate = mockVaultDelegate
        payPalClient.vault(url: url!)

        waitForExpectations(timeout: 10)
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let url = URL(string: "https://sandbox.paypal.com/vault")
        let expectedError = CoreSDKError(
            code: PayPalWebCheckoutClientError.payPalVaultResponseError.code,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: PayPalWebCheckoutClientError.payPalVaultResponseError.errorDescription
        )

        let mockVaultDelegate = MockPayPalVaultDelegate(success: {_, _ in
            XCTFail("Invoked success() callback. Should invoke error().")
        }, error: {_, vaultError in
            XCTAssertEqual(vaultError.code, expectedError.code)
            expectation.fulfill()
        })
        payPalClient.vaultDelegate = mockVaultDelegate
        payPalClient.vault(url: url!)

        waitForExpectations(timeout: 10)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        payPalClient.start(request: request)

        XCTAssertTrue(delegate.paypalDidCancel)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: "Mock web session error description."
        )

        payPalClient.start(request: request)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalWebCheckoutClientError.domain)
        XCTAssertEqual(error?.code, PayPalWebCheckoutClientError.Code.webSessionError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Mock web session error description.")
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        payPalClient.start(request: request)

        let error = delegate.capturedError

        XCTAssertEqual(error?.domain, PayPalWebCheckoutClientError.domain)
        XCTAssertEqual(error?.code, PayPalWebCheckoutClientError.Code.malformedResultError.rawValue)
        XCTAssertEqual(error?.localizedDescription, "Result did not contain the expected data.")
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")
        let delegate = MockPayPalWebDelegate()

        payPalClient.delegate = delegate
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        payPalClient.start(request: request)

        let result = delegate.capturedResult

        XCTAssertEqual(result?.orderID, "1234")
        XCTAssertEqual(result?.payerID, "98765")
    }

    func testpayPalCheckoutReturnURL_returnsCorrectURL() {
        let url = URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234")!
        let checkoutURL = payPalClient.payPalCheckoutReturnURL(payPalCheckoutURL: url)

        XCTAssertEqual(
            checkoutURL,
            URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234&redirect_uri=sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout&native_xo=1")
        )
    }
}
