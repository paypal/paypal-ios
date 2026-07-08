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
    var mockCreateShopperSessionAPI: MockCreateShopperSessionAPI!
    var mockURLOpener: MockURLOpener!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", merchantID: "test-merchant-id", environment: .sandbox)
        mockTrackingEventsAPI = MockTrackingEventsAPI(coreConfig: config)
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

    func test_start_sendsAPIRequestLatencyForCreateOrder() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        _ = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })

        let latencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.apiRequestLatency
            }
        )
        XCTAssertEqual(latencyEvent.endpoint, PayPalWebAnalytics.createOrderEndpoint)
        XCTAssertNotNil(latencyEvent.startTime)
        XCTAssertNotNil(latencyEvent.endTime)
        XCTAssertGreaterThanOrEqual(latencyEvent.endTime!, latencyEvent.startTime!)
    }

    func test_start_sendsSystemLatencyForBrowserPresentation() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id"
        )

        _ = try await payPalClient.start(request: .testDefault(), createOrder: { "test-order-id" })

        let systemLatencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent.presentationType, PayPalWebAnalytics.PresentationType.browser)
        XCTAssertEqual(systemLatencyEvent.flow, PayPalWebAnalytics.Flow.checkout)
        XCTAssertNotNil(systemLatencyEvent.startTime)
        XCTAssertNotNil(systemLatencyEvent.endTime)
    }

    func test_vault_sendsAPIRequestLatencyForCreateSession() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-id&approval_session_id=session-id"
        )

        _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "setup-token-id" })

        let latencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.apiRequestLatency
            }
        )
        XCTAssertEqual(latencyEvent.endpoint, PayPalWebAnalytics.createSessionEndpoint)
        XCTAssertNotNil(latencyEvent.startTime)
        XCTAssertNotNil(latencyEvent.endTime)
    }

    func test_vault_sendsSystemLatencyForBrowserPresentation() async throws {
        mockCreateShopperSessionAPI.stubSession = ShopperSessionWithAppSwitchEligibility.stub(ssidRouting: true, appSwitchEligible: false)
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-id&approval_session_id=session-id"
        )

        _ = try await payPalClient.vault(.testDefault(), createSetupToken: { "setup-token-id" })

        let systemLatencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent.presentationType, PayPalWebAnalytics.PresentationType.browser)
        XCTAssertEqual(systemLatencyEvent.flow, PayPalWebAnalytics.Flow.vault)
    }

    func test_start_withInvalidUserAction_sendsSystemLatencyError() async {
        let expectation = expectation(description: "completion")
        payPalClient.start(request: .testDefault(userAction: .setupNow), createOrder: { "order-id" }) { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        let systemLatencyEvent = try? XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.systemLatency
            }
        )
        XCTAssertEqual(systemLatencyEvent?.presentationType, PayPalWebAnalytics.PresentationType.error)
        XCTAssertEqual(systemLatencyEvent?.flow, PayPalWebAnalytics.Flow.checkout)
    }
}
