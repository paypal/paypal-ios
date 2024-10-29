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
    
    func testVault_whenSandbox_launchesCorrectURLInWebSession() {
        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")
        payPalClient.vault(vaultRequest) { _, _ in }

        XCTAssertEqual(mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://sandbox.paypal.com/agreements/approve?approval_session_id=fake-token")
    }
    
    func testVault_whenLive_launchesCorrectURLInWebSession() {
        config = CoreConfig(clientID: "testClientID", environment: .live)
        let payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        
        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")
        payPalClient.vault(vaultRequest) { _, _ in }

        XCTAssertEqual(mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://paypal.com/agreements/approve?approval_session_id=fake-token")
    }
    
    func testVault_whenSuccessUrl_ReturnsVaultToken() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let expectedTokenIDResult = "fakeTokenID"
        let expectedSessionIDResult = "fakeSessionID"

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result, error in
            XCTAssertEqual(expectedTokenIDResult, result?.tokenID)
            XCTAssertEqual(expectedSessionIDResult, result?.approvalSessionID)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_whenWebSession_cancelled() {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
                XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.payPalVaultCancellationError.rawValue)
                XCTAssertEqual(error.localizedDescription, "PayPal vault has been cancelled by the user")
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }

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

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let expectedError = CoreSDKError(
            code: PayPalWebCheckoutClientError.payPalVaultResponseError.code,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: PayPalWebCheckoutClientError.payPalVaultResponseError.errorDescription
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testStart_whenWebAuthenticationSessionCancelCalled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
                XCTAssertEqual(error.code, PayPalWebCheckoutClientError.payPalCancellationError.code)
                XCTAssertEqual(error.localizedDescription, PayPalWebCheckoutClientError.payPalCancellationError.localizedDescription)
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
                XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.webSessionError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result, error in
            XCTAssertNil(result)
            if let error = error as? CoreSDKError {
                XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
                XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.malformedResultError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Result did not contain the expected data.")
            } else {
                XCTFail("Expected error to be of type CoreSDKError")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result, error in
            XCTAssertEqual(result?.orderID, "1234")
            XCTAssertEqual(result?.payerID, "98765")
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
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
