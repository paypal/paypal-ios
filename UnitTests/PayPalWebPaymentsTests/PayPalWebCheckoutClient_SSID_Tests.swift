import XCTest
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalWebCheckoutClient_SSID_Tests: XCTestCase {

    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockCreateShopperSessionAPI: MockCreateShopperSessionAPI!
    var mockURLOpener: MockURLOpener!

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
        mockURLOpener = MockURLOpener()

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        payPalClient.application = mockURLOpener
    }

    func test_ssidRouting_true_eligible_appInstalled_invokesAppSwitch() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: true)
        mockURLOpener.mockOpenURLSuccess = true

        let urlOpened = expectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = { urlOpened.fulfill() }

        payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" }) { _ in }

        await fulfillment(of: [urlOpened], timeout: 1.0)

        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNotNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(
            mockURLOpener.lastOpenedURL?.absoluteString,
            "https://www.sandbox.paypal.com/app-checkout?token=test-order-id&source=pda&merchant=testClientID&flow_type=ecs&sessionID=ssid_test"
        )
    }

    func test_ssidRouting_true_ineligible_invokesBrowserFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        let result = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })

        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://www.sandbox.paypal.com/web-checkout?token=test-order-id&sessionID=ssid_test"
        )
        XCTAssertEqual(result.orderID, "test-order-id")
        XCTAssertEqual(result.payerID, "test-payer-id")
    }

    func test_ssidRouting_false_fallsBackToPatchCCO() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: false)
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: false,
            redirectURL: nil,
            ineligibleReason: nil
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        let result = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })

        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertEqual(result.orderID, "test-order-id")
    }

    func test_sessionError_fallsBackToPatchCCO() async throws {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(code: 500, domain: "gql", errorDescription: "fail")
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: false,
            redirectURL: nil,
            ineligibleReason: nil
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        let result = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })
        XCTAssertEqual(result.orderID, "test-order-id")
    }

    func test_appSwitchOpenFailure_fallsBackToBrowser() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: true)
        mockURLOpener.mockOpenURLSuccess = false
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        let result = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })

        XCTAssertNotNil(mockURLOpener.lastOpenedURL)
        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertEqual(result.payerID, "test-payer-id")
    }

    func test_patchCCO_passesPayPalAppInstalledFlag() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: false)
        mockPatchCCOAPI.stubEligibilityResponse = AppSwitchEligibility(
            appSwitchEligible: false,
            redirectURL: nil,
            ineligibleReason: nil
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        _ = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })
        XCTAssertEqual(mockPatchCCOAPI.capturedPaypalNativeAppInstalled, true)
    }

    func test_vault_ssidRouting_false_usesLegacyWebVault() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=test-setup-token&approval_session_id=test-session-id"
        )

        let result = try await payPalClient.vault(.testDefault(), createSetupToken: { "test-setup-token" })

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://sandbox.paypal.com/agreements/approve?approval_session_id=test-setup-token&integration_artifact=MOBILE_SDK"
        )
        XCTAssertNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.tokenID, "test-setup-token")
    }

    func test_vault_sessionError_fallsBackToLegacyWebVault() async throws {
        mockCreateShopperSessionAPI.stubError = CoreSDKError(code: 500, domain: "gql", errorDescription: "fail")
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-1&approval_session_id=session-1"
        )

        _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "token-1" })

        XCTAssertEqual(
            mockWebAuthenticationSession.lastLaunchedURL?.absoluteString,
            "https://sandbox.paypal.com/agreements/approve?approval_session_id=token-1&integration_artifact=MOBILE_SDK"
        )
    }

    func test_parallelExecution_callsSessionAndCreateOrder() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=order-1&PayerID=payer-1"
        )

        _ = try await payPalClient.start(request: .testDefault(), createOrder: { "order-1" })

        XCTAssertEqual(mockCreateShopperSessionAPI.checkoutCallCount, 1)
    }
}
