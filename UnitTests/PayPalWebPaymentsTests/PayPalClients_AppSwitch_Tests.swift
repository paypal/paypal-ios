import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalClient_AppSwitch_Tests: XCTestCase {

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
        // Second call should do nothing because appSwitchCompletion was cleared
        payPalClient.handleReturnURL(url)

        XCTAssertEqual(completionCount, 1, "Completion should be called exactly once")
        XCTAssertNil(payPalClient.appSwitchCompletion)
    }

    func testHandleReturnURL_success_callsVaultAppSwitchCompletionWithResult() {
        var received: Result<PayPalVaultResult, CoreSDKError>?
        payPalClient.vaultAppSwitchCompletion = { received = $0 }

        let url = URL(string:
            "https://appSwitchURL/success?approval_token_id=345&approval_session_id=12345&PayerID=PAYER456&switch_initiated_time=1757431432185")!

        payPalClient.handleReturnURL(url)

        switch received {
        case .success(let result)?:
            XCTAssertEqual(result.approvalSessionID, "12345")
            XCTAssertEqual(result.tokenID, "345")
        default:
            XCTFail("Expected success with PayPalVaultResult")
        }

        XCTAssertNil(payPalClient.vaultAppSwitchCompletion)
    }

    func testHandleReturnURL_cancel_mapsToVaultCheckoutCanceledError() {
        var received: Result<PayPalVaultResult, CoreSDKError>?
        payPalClient.vaultAppSwitchCompletion = { received = $0 }

        let url = URL(string:
            "https://appSwitchURL/cancel?approval_token_id=345&approval_session_id=12345&PayerID=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)

        if case .failure(let error)? = received {
            XCTAssertTrue(PayPalError.isVaultCanceled(error))
        } else {
            XCTFail("Expected cancellation error")
        }
        XCTAssertNil(payPalClient.vaultAppSwitchCompletion)
    }

    func testHandleReturnURL_successPathMissingTokenID_isMalformedResultError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        // Missing token
        let url = URL(string:
            "https://appSwitchURL/success?approval_session_id=12345&PayerID=PAYER456&switch_initiated_time=1757431432185"
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


    func testHandleReturnURL_successPathMissingApprovalSessionID_isMalformedResultError() {
        var received: Result<PayPalWebCheckoutResult, CoreSDKError>?
        payPalClient.appSwitchCompletion = { received = $0 }

        // Missing token
        let url = URL(string:
            "https://appSwitchURL/success?PayerID=PAYER456&switch_initiated_time=1757431432185"
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

    func testHandleReturnURL_onlyCompletesOnce_forVault() {
        var completionCount = 0
        payPalClient.vaultAppSwitchCompletion = { _ in completionCount += 1 }

        let url = URL(string:
            "https://appSwitchURL/success?approval_token_id=345&approval_session_id=12345&PayerID=PAYER456&switch_initiated_time=1757431432185"
        )!

        payPalClient.handleReturnURL(url)
        // Second call should do nothing because vaultAppSwitchCompletion was cleared
        payPalClient.handleReturnURL(url)

        XCTAssertEqual(completionCount, 1, "Completion should be called exactly once")
        XCTAssertNil(payPalClient.vaultAppSwitchCompletion)
    }
}
