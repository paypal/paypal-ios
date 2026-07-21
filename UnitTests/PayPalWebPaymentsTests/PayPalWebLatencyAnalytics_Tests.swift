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

    private let fakeURLConfig = PayPalURLConfig(
        returnAppURL: URL(string: "paypal://return")!,
        cancelAppURL: URL(string: "paypal://cancel")!,
        fallbackSchemeURL: URL(string: "paypal://fallback")!
    )

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
        mockCreateShopperSessionAPI = MockCreateShopperSessionAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: MockNetworkingClient(http: MockHTTP(coreConfig: config)),
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        payPalClient.urlOpener = mockURLOpener
        payPalClient.analyticsServiceProviderFactory = { [self] config, orderID, setupToken in
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

    private func makeIneligibleSession() -> ShopperSessionResult {
        ShopperSessionResult(
            appSwitchEligible: false,
            redirectURL: nil,
            ineligibleReason: "TEST_INELIGIBLE",
            matchedAuthenticationMethods: nil,
            shopperSessionConfig: .init(id: "fake-session-id", expiresAt: "2026-12-31T00:00:00Z")
        )
    }

    private func makeEligibleSession(redirectURL: String) -> ShopperSessionResult {
        ShopperSessionResult(
            appSwitchEligible: true,
            redirectURL: redirectURL,
            ineligibleReason: nil,
            matchedAuthenticationMethods: ["EMAIL"],
            shopperSessionConfig: .init(id: "fake-session-id", expiresAt: "2026-12-31T00:00:00Z")
        )
    }

    func test_start_sendsSystemLatencyForBrowserPresentation() async throws {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalWebCheckoutResult, Error>) in
            payPalClient.start(orderID: "test-order-id") { checkoutResult in
                switch checkoutResult {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        XCTAssertEqual(result.orderID, "test-order-id")

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
        mockCreateShopperSessionAPI.stubResponse = makeEligibleSession(
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?token=test-order-id"
        )
        mockURLOpener.mockOpenURLSuccess = true

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)
        payPalClient.start(orderID: "test-order-id") { _ in }

        await fulfillment(of: [urlOpenedExpectation], timeout: 2.0)

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
        mockCreateShopperSessionAPI.stubResponse = makeEligibleSession(
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?token=test-order-id"
        )
        mockURLOpener.mockOpenURLSuccess = false
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalWebCheckoutResult, Error>) in
            payPalClient.start(orderID: "test-order-id") { checkoutResult in
                switch checkoutResult {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        XCTAssertEqual(result.orderID, "test-order-id")

        let systemLatencyEvents = mockTrackingEventsAPI.capturedAnalyticsEvents.filter {
            $0.eventName == PayPalWebAnalytics.systemLatency
        }
        XCTAssertEqual(systemLatencyEvents.count, 1)
        XCTAssertEqual(systemLatencyEvents.first?.presentationType, PayPalWebAnalytics.PresentationType.appSwitch)
    }

    func test_vault_sendsSystemLatencyForBrowserPresentation() async throws {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-id&approval_session_id=session-id"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalVaultResult, Error>) in
            payPalClient.vault(setupTokenID: "setup-token-id") { vaultResult in
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

    func test_start_withCreateOrder_sendsAPIRequestLatencyForCreateOrder() async throws {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        _ = try await payPalClient.start(createOrder: {
            "test-order-id"
        })

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

    func test_vault_withCreateSetupToken_sendsAPIRequestLatencyForCreateSession() async throws {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://vault/success?approval_token_id=token-id&approval_session_id=session-id"
        )

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        _ = try await payPalClient.vault(createSetupToken: {
            "setup-token-id"
        })

        let latencyEvent = try XCTUnwrap(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.apiRequestLatency
            }
        )
        XCTAssertEqual(latencyEvent.endpoint, PayPalWebAnalytics.createSessionEndpoint)
        XCTAssertNotNil(latencyEvent.startTime)
        XCTAssertNotNil(latencyEvent.endTime)
    }

    func test_start_createOrderFailure_sendsAPIRequestLatencyAndSystemLatencyError() async {
        struct CreateOrderError: Error {}
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)

        let expectation = expectation(description: "start fails")
        payPalClient.start(createOrder: {
            throw CreateOrderError()
        }) { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)

        let apiLatencyEvent = mockTrackingEventsAPI.capturedAnalyticsEvents.first {
            $0.eventName == PayPalWebAnalytics.apiRequestLatency
        }
        XCTAssertEqual(apiLatencyEvent?.endpoint, PayPalWebAnalytics.createOrderEndpoint)

        let systemLatencyEvent = mockTrackingEventsAPI.capturedAnalyticsEvents.first {
            $0.eventName == PayPalWebAnalytics.systemLatency
        }
        XCTAssertEqual(systemLatencyEvent?.presentationType, PayPalWebAnalytics.PresentationType.error)
        XCTAssertEqual(systemLatencyEvent?.flow, PayPalWebAnalytics.Flow.checkout)
    }

    func test_start_withOrderID_doesNotSendAPIRequestLatency() async throws {
        mockCreateShopperSessionAPI.stubResponse = makeIneligibleSession()
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL = URL(string: checkoutSuccessInboundDeepLink)

        payPalClient.createPayPalSession(urlConfig: fakeURLConfig)
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalWebCheckoutResult, Error>) in
            payPalClient.start(orderID: "test-order-id") { result in
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }

        XCTAssertNil(
            mockTrackingEventsAPI.capturedAnalyticsEvents.first {
                $0.eventName == PayPalWebAnalytics.apiRequestLatency
            }
        )
    }
}
