import XCTest
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalWebLatencyAnalytics_Tests: XCTestCase {

    var config: CoreConfig!
    var mockTrackingEventsAPI: MockTrackingEventsAPI!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockURLOpener: MockURLOpener!

    private let checkoutSuccessInboundDeepLink =
        "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockTrackingEventsAPI = MockTrackingEventsAPI(coreConfig: config)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockClientConfigAPI = MockClientConfigAPI(
            coreConfig: config,
            networkingClient: MockNetworkingClient(http: MockHTTP(coreConfig: config))
        )
        mockPatchCCOAPI = MockPatchCCOAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: MockNetworkingClient(http: MockHTTP(coreConfig: config)),
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        payPalClient.urlOpener = mockURLOpener
        payPalClient.unitTestAnalyticsServiceProvider = { [self] config, orderID, setupToken in
            if let orderID {
                return AnalyticsService(
                    coreConfig: config,
                    orderID: orderID,
                    trackingEventsAPI: self.mockTrackingEventsAPI
                )
            }
            if let setupToken {
                return AnalyticsService(
                    coreConfig: config,
                    setupToken: setupToken,
                    trackingEventsAPI: self.mockTrackingEventsAPI
                )
            }
            return AnalyticsService(coreConfig: config, trackingEventsAPI: self.mockTrackingEventsAPI)
        }
    }

    func test_start_sendsSystemLatencyForBrowserPresentation() async throws {
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        _ = try await payPalClient.start(request: PayPalWebCheckoutRequest(orderID: "test-order-id"))

        let systemLatencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent.presentationType, PayPalWebAnalytics.PresentationType.browser)
        XCTAssertEqual(systemLatencyEvent.flow, PayPalWebAnalytics.Flow.checkout)
        XCTAssertNotNil(systemLatencyEvent.startTime)
        XCTAssertNotNil(systemLatencyEvent.endTime)
        XCTAssertGreaterThanOrEqual(systemLatencyEvent.endTime!, systemLatencyEvent.startTime!)
    }

    func test_start_sendsSystemLatencyForAppSwitchPresentation() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true

        let eligibleResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?appSwitchEligible=true&token=test-order-id&tokenType=ORDER_ID",
            ineligibleReason: nil
        )
        mockPatchCCOAPI.stubEligibilityResponse = eligibleResponse
        mockURLOpener.mockOpenURLSuccess = true

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }

        payPalClient.start(request: PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)) { _ in }

        await fulfillment(of: [urlOpenedExpectation], timeout: 1.0)

        let systemLatencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent.presentationType, PayPalWebAnalytics.PresentationType.appSwitch)
        XCTAssertEqual(systemLatencyEvent.flow, PayPalWebAnalytics.Flow.checkout)
    }

    func test_start_appSwitchFallbackToWeb_sendsSystemLatencyOnceAsAppSwitch() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true

        let eligibleResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?appSwitchEligible=true&token=test-order-id&tokenType=ORDER_ID",
            ineligibleReason: nil
        )
        mockPatchCCOAPI.stubEligibilityResponse = eligibleResponse
        mockURLOpener.mockOpenURLSuccess = false
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        _ = try await payPalClient.start(
            request: PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)
        )

        let systemLatencyEvents = mockTrackingEventsAPI.capturedAnalyticsEvents.filter {
            $0.eventName == PayPalWebAnalytics.systemLatency
        }
        XCTAssertEqual(systemLatencyEvents.count, 1)
        XCTAssertEqual(systemLatencyEvents.first?.presentationType, PayPalWebAnalytics.PresentationType.appSwitch)
    }

    func test_vault_sendsSystemLatencyForBrowserPresentation() async throws {
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-id&approval_session_id=session-id"
        )

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalVaultResult, Error>) in
            payPalClient.vault(PayPalVaultRequest(setupTokenID: "setup-token-id")) { vaultResult in
                switch vaultResult {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        XCTAssertEqual(result.tokenID, "token-id")

        let systemLatencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent.presentationType, PayPalWebAnalytics.PresentationType.browser)
        XCTAssertEqual(systemLatencyEvent.flow, PayPalWebAnalytics.Flow.vault)
        XCTAssertNotNil(systemLatencyEvent.startTime)
        XCTAssertNotNil(systemLatencyEvent.endTime)
    }
}
