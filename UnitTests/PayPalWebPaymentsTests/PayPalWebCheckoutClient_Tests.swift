import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

// swiftlint: disable type_body_length file_length
class PayPalClient_Tests: XCTestCase {
    
    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!


    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)


        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }
    
    func testVault_whenSandbox_launchesCorrectURLInWebSession() {
        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        let started = expectation(description: "ASWebAuthenticationSession Started")
        mockWebAuthenticationSession.onStart = { started.fulfill() }

        payPalClient.vault(vaultRequest) { _ in }
        wait(for: [started], timeout: 1.0)

        XCTAssertEqual(mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://sandbox.paypal.com/agreements/approve?approval_session_id=fake-token")
    }

    func testVault_whenLive_launchesCorrectURLInWebSession() {
        config = CoreConfig(clientID: "testClientID", environment: .live)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        let started = expectation(description: "ASWebAuthenticationSession Started")
        mockWebAuthenticationSession.onStart = { started.fulfill() }

        let payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")
        payPalClient.vault(vaultRequest) { _ in }
        wait(for: [started], timeout: 1.0)

        XCTAssertEqual(mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://paypal.com/agreements/approve?approval_session_id=fake-token")
    }

    func testVault_whenSuccessUrl_ReturnsVaultToken() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let expectedTokenIDResult = "fakeTokenID"
        let expectedSessionIDResult = "fakeSessionID"

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success(let cardVaultResult):
                XCTAssertEqual(expectedTokenIDResult, cardVaultResult.tokenID)
                XCTAssertEqual(expectedSessionIDResult, cardVaultResult.approvalSessionID)
            case .failure:
                XCTFail("Expected success with CardVaultResult")
            }
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
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
                XCTAssertEqual(error.localizedDescription, "PayPal vault has been canceled by the user")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_cancelled_returnsIsVaultCanceledTrue() {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with cancellation error")
            case .failure(let error):
                XCTAssertTrue(PayPalError.isVaultCanceled(error))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_returnsDefaultError() {

        let expectedError = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: PayPalError.payPalVaultResponseError.errorDescription
        )
        mockWebAuthenticationSession.cannedErrorResponse = expectedError

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() {
        
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID")
        
        let expectation = expectation(description: "vault(url:) completed")
        
        let expectedError = CoreSDKError(
            code: PayPalError.payPalVaultResponseError.code,
            domain: PayPalError.domain,
            errorDescription: PayPalError.payPalVaultResponseError.errorDescription
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testStart_whenWebAuthenticationSessionCancelCalled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.checkoutCanceledError.code)
                XCTAssertEqual(error.localizedDescription, PayPalError.checkoutCanceledError.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebSession_cancelled_returnsIsCheckoutCanceledTrue() {

        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertTrue(PayPalError.isCheckoutCanceled(error))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = self.expectation(description: "Call back invoked with error")

        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.webSessionError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: nil)

        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.malformedResultError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Result did not contain the expected data.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(result.orderID, "1234")
                XCTAssertEqual(result.payerID, "98765")
            case .failure:
                XCTFail("Expected success with PayPalCheckoutResult")
            }
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

    // MARK: - handleReturnURL tests

    func testHandleReturnURL_success_callsAppSwitchCompletionWithResult() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        let url = URL(string:
            "https://appSwitchURL/success?token=ORDER123&PayerID=PAYER456&switch_initiated_time=1757431432185")!

        payPalClient.handleReturnURL(url)

        switch received {
        case .success(let result)?:
            XCTAssertEqual(result.orderID, "ORDER123")
            XCTAssertEqual(result.payerID, "PAYER456")
        default:
            XCTFail("Expected success with PayPalWebCheckoutResult")
        }

        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_cancel_mapsToCheckoutCanceledError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        let url = URL(string:
            "https://appSwitchURL/cancel?token=ORDER123&PayerID=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertTrue(PayPalError.isCheckoutCanceled(error))
        } else {
            XCTFail("Expected cancellation error")
        }
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_failPath_mapsToUnknownError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        let url = URL(string:
            "https://appSwitchURL/fail?token=ORDER123&PayerID=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertEqual(error.code, PayPalError.malformedResultError.code)
            XCTAssertEqual(error.domain, PayPalError.domain)
        } else {
            XCTFail("Expected unknown error")
        }
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_successPathMissingPayerID_isMalformedResultError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        // Missing PayerID
        let url = URL(string:
            "https://appSwitchURL/success?token=ORDER123&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertEqual(error.code, PayPalError.malformedResultError.code)
            XCTAssertEqual(error.domain, PayPalError.domain)
        } else {
            XCTFail("Expected malformedResultError")
        }
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_successPathIncorrectPayerIdFormat_isMalformedResultError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        // Should be PayerID
        let url = URL(string:
            "https://appSwitchURL/success?token=ORDER123&PayerId=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertEqual(error.code, PayPalError.malformedResultError.code)
            XCTAssertEqual(error.domain, PayPalError.domain)
        } else {
            XCTFail("Expected malformedResultError")
        }
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_successPathIncorrectPayeridFormat_isMalformedResultError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        // Should be PayerID
        let url = URL(string:
            "https://appSwitchURL/success?token=ORDER123&Payer_id=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertEqual(error.code, PayPalError.malformedResultError.code)
            XCTAssertEqual(error.domain, PayPalError.domain)
        } else {
            XCTFail("Expected malformedResultError")
        }
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL__onlyCompletesOnce() {
        var completionCount = 0
        payPalClient.appSwitchCompletion = { _ in completionCount += 1 }

        let url = URL(string:
            "https://appSwitchURL/success?token=ORDER123&PayerID=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)
        // Second call should do nothing because appSwitchCompletion was cleared via defer
        payPalClient.handleReturnURL(url)

        XCTAssertEqual(completionCount, 1, "Completion should be called exactly once")
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }
}
// swiftlint:enable type_body_length
