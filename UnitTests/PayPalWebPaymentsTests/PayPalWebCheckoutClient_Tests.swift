import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

// swiftlint: disable type_body_length
class PayPalClient_Tests: XCTestCase {

    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockCreateShopperSessionAPI: MockCreateShopperSessionAPI!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", merchantID: "test-merchant-id", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockClientConfigAPI = MockClientConfigAPI(
            coreConfig: config,
            networkingClient: MockNetworkingClient(http: MockHTTP(coreConfig: config))
        )
        mockPatchCCOAPI = MockPatchCCOAPI()
        mockCreateShopperSessionAPI = MockCreateShopperSessionAPI()
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: false)

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }

    private func stubPatchCCOIneligible() {
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: false,
            redirectURL: nil,
            ineligibleReason: "test-ineligible"
        )
    }

    func testVault_whenSandbox_launchesCorrectURLInWebSession() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(
            appSwitchEligible: false
        )
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=fake-token&approval_session_id=fake-session-id"
        )

        let started = expectation(description: "ASWebAuthenticationSession Started")
        mockWebAuthenticationSession.onStart = { started.fulfill() }

        try await payPalClient.vault(.testDefault(), createSetupToken: { "fake-token" })
        await fulfillment(of: [started], timeout: 1.0)

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://www.sandbox.paypal.com/web-approval?approval_session_id=fake-token&sessionID=ssid_test"
        )
    }

    func testVault_whenLive_launchesCorrectURLInWebSession() async throws {
        config = CoreConfig(clientID: "testClientID", merchantID: "test-merchant-id", environment: .live)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(
            appSwitchEligible: false
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=fake-token&approval_session_id=fake-session-id"
        )

        let started = expectation(description: "ASWebAuthenticationSession Started")
        mockWebAuthenticationSession.onStart = { started.fulfill() }

        let payPalClient = PayPalWebCheckoutClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )

        try await payPalClient.vault(.testDefault(), createSetupToken: { "fake-token" })
        await fulfillment(of: [started], timeout: 1.0)

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://www.sandbox.paypal.com/web-approval?approval_session_id=fake-token&sessionID=ssid_test"
        )
    }

    func testVault_whenSuccessUrl_ReturnsVaultToken() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID"
        )

        let result = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
        XCTAssertEqual(result.tokenID, "fakeTokenID")
        XCTAssertEqual(result.approvalSessionID, "fakeSessionID")
    }

    func testVault_whenCancelUrl_ReturnsVaultToken() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL =
            URL(string: "sdk.ios.paypal://testurl.com/checkout/cancel?approval_session_id=$approvalSessionId")

        do {
            _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
            XCTAssertEqual(error.localizedDescription, "PayPal vault has been canceled by the user")
        }
    }

    func testVault_whenWebSession_cancelled() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        do {
            _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
        }
    }

    func testVault_whenWebSession_cancelled_returnsIsVaultCanceledTrue() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        do {
            _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
            XCTFail("Expected failure with cancellation error")
        } catch let error as CoreSDKError {
            XCTAssertTrue(PayPalError.isVaultCanceled(error))
        }
    }

    func testVault_whenWebSession_returnsDefaultError() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        let expectedError = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: PayPalError.payPalVaultResponseError.errorDescription
        )
        mockWebAuthenticationSession.cannedErrorResponse = expectedError

        do {
            _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        }
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID"
        )

        do {
            _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.payPalVaultResponseError.code)
        }
    }

    func testVault_whenSessionFails_fallsBackToLegacyWebVault() async throws {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(
            code: 500,
            domain: "session",
            errorDescription: "session failed"
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID"
        )

        let result = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://sandbox.paypal.com/agreements/approve?approval_session_id=fakeTokenID&integration_artifact=MOBILE_SDK"
        )
        XCTAssertEqual(result.tokenID, "fakeTokenID")
    }

    func testVault_whenSsidRoutingFalse_usesLegacyWebVault() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID"
        )

        let result = try await payPalClient.vault(.testDefault(), createSetupToken: { "fakeTokenID" })

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://sandbox.paypal.com/agreements/approve?approval_session_id=fakeTokenID&integration_artifact=MOBILE_SDK"
        )
        XCTAssertEqual(result.tokenID, "fakeTokenID")
    }

    func testStart_whenSetupNowUserAction_returnsError() async throws {
        do {
            _ = try await payPalClient.start(
                request: PayPalWebCheckoutRequest(urlConfig: .testDefault, userAction: .setupNow),
                createOrder: { "1234" }
            )
            XCTFail("Expected invalid user action error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.code, PayPalError.invalidUserActionError.code)
        }
    }

    func testStart_whenWebAuthenticationSessionCancelCalled_returnsCancellationError() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        do {
            _ = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.checkoutCanceledError.code)
        }
    }

    func testStart_whenWebSession_cancelled_returnsIsCheckoutCanceledTrue() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        do {
            _ = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertTrue(PayPalError.isCheckoutCanceled(error))
        }
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Mock web session error description."
        )

        do {
            _ = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.webSessionError.rawValue)
        }
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")

        do {
            _ = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.malformedResultError.rawValue)
        }
    }

    func testStart_whenWebResultIsCancelled_returnsCancellationError() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedResponseURL =
            URL(string: "sdk.ios.paypal://testurl.com/checkout?opType=cancel")

        do {
            _ = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
            XCTFail("Expected failure with error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.checkoutCanceledError.rawValue)
        }
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() async throws {
        stubPatchCCOIneligible()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")

        let result = try await payPalClient.start(request: .testDefault(), createOrder: { "1234" })
        XCTAssertEqual(result.orderID, "1234")
        XCTAssertEqual(result.payerID, "98765")
    }

    func testStart_whenCreateOrderFails_returnsError() async throws {
        do {
            _ = try await payPalClient.start(request: .testDefault()) {
                throw CoreSDKError(code: 400, domain: "order", errorDescription: "create order failed")
            }
            XCTFail("Expected failure")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, "order")
            XCTAssertEqual(error.code, 400)
        }
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
// swiftlint:enable type_body_length
