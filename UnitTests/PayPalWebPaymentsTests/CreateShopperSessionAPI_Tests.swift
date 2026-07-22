import XCTest
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class CreateShopperSessionAPI_Tests: XCTestCase {

    // MARK: - Helpers

    /// Captures the analytics events dispatched by the (fire-and-forget) `AnalyticsService`.
    private class CapturingTrackingEventsAPI: TrackingEventsAPI {

        var capturedEventData: AnalyticsEventData?
        var onSendEvent: (() -> Void)?

        override func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
            capturedEventData = analyticsEventData
            onSendEvent?()
            return HTTPResponse(status: 200, body: nil)
        }
    }

    private let successGraphQLBody = """
        {
            "data": {
                "external": {
                    "createShopperSessionWithAppSwitchEligibility": {
                        "appSwitchEligibilityResponse": {
                            "appSwitchEligible": true,
                            "ineligibleReason": null,
                            "checkoutUrls": {
                                "redirectURL": "https://paypal.com/app-switch",
                                "checkoutFallbackUrl": null
                            }
                        },
                        "shopperSessionResponse": {
                            "sessionId": "fake-session-id",
                            "expiresAt": "2026-12-31T00:00:00Z"
                        }
                    }
                }
            }
        }
        """

    var config: CoreConfig!
    var mockNetworkingClient: MockNetworkingClient!
    var mockAuthAPI: MockAuthenticationSecureTokenServiceAPI!
    private var capturingTrackingEventsAPI: CapturingTrackingEventsAPI!
    var mockURLOpener: MockURLOpener!
    var sut: CreateShopperSessionAPI!

    let fakeURLConfig = PayPalURLConfig(
        returnAppURL: URL(string: "paypal://return")!,
        cancelAppURL: URL(string: "paypal://cancel")!,
        fallbackSchemeURL: URL(string: "paypal://fallback")!
    )

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockAuthAPI = MockAuthenticationSecureTokenServiceAPI(coreConfig: config)
        capturingTrackingEventsAPI = CapturingTrackingEventsAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()

        let analyticsService = AnalyticsService(
            coreConfig: config,
            orderID: "unused-for-latency",
            trackingEventsAPI: capturingTrackingEventsAPI
        )

        sut = CreateShopperSessionAPI(
            coreConfig: config,
            networkingClient: mockNetworkingClient,
            authenticationSecureTokenServiceAPI: mockAuthAPI,
            analyticsService: analyticsService
        )
    }

    // MARK: - api-request-latency

    func testCreateShopperSession_whenResponseHasTiming_firesAPIRequestLatencyEvent() async throws {
        mockNetworkingClient.stubHTTPResponse = HTTPResponse(
            status: 200,
            body: successGraphQLBody.data(using: .utf8),
            url: URL(string: "https://paypal.com/graphql"),
            timing: HTTPResponse.Timing(startTime: 1_700_000_000_000, endTime: 1_700_000_000_250)
        )

        let expectation = expectation(description: "api-request-latency event sent")
        capturingTrackingEventsAPI.onSendEvent = { expectation.fulfill() }

        _ = try await sut.createShopperSessionWithAppSwitchEligibility(
            tokenType: .orderID,
            urlOpener: mockURLOpener,
            urlConfig: fakeURLConfig,
            userIdentity: nil
        )

        await fulfillment(of: [expectation], timeout: 2.0)

        let captured = capturingTrackingEventsAPI.capturedEventData
        XCTAssertEqual(captured?.eventName, "paypal-web-payments:api-request-latency")
        XCTAssertEqual(captured?.startTime, 1_700_000_000_000)
        XCTAssertEqual(captured?.endTime, 1_700_000_000_250)
        XCTAssertEqual(captured?.endpoint, "/graphql/createShopperSessionWithAppSwitchEligibility")
    }
}
