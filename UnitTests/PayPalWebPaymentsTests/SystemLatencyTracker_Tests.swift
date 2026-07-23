import XCTest
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class SystemLatencyTracker_Tests: XCTestCase {

    // MARK: - Helpers

    /// Captures analytics events dispatched by the (fire-and-forget) `AnalyticsService`.
    private final class CapturingTrackingEventsAPI: TrackingEventsAPI {

        var capturedEventData: AnalyticsEventData?
        var sendCount = 0
        var onSendEvent: (() -> Void)?

        override func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
            sendCount += 1
            capturedEventData = analyticsEventData
            onSendEvent?()
            return HTTPResponse(status: 200, body: nil)
        }
    }

    var config: CoreConfig!
    private var capturingTrackingEventsAPI: CapturingTrackingEventsAPI!
    var analyticsService: AnalyticsService!
    var sut: SystemLatencyTracker!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        capturingTrackingEventsAPI = CapturingTrackingEventsAPI(coreConfig: config)
        analyticsService = AnalyticsService(
            coreConfig: config,
            orderID: "test-order-id",
            trackingEventsAPI: capturingTrackingEventsAPI
        )
        sut = SystemLatencyTracker()
    }

    // MARK: - send(...)

    func testSend_withoutBegin_doesNotEmit() {
        sut.send(presentationType: .browser, using: analyticsService, checkoutAnalyticsData: nil)

        XCTAssertEqual(capturingTrackingEventsAPI.sendCount, 0)
        XCTAssertNil(capturingTrackingEventsAPI.capturedEventData)
    }

    func testSend_afterBegin_emitsEventWithParameters() async {
        let expectation = expectation(description: "system-latency event sent")
        capturingTrackingEventsAPI.onSendEvent = { expectation.fulfill() }

        sut.begin(flow: .checkout)
        sut.send(presentationType: .browser, using: analyticsService, checkoutAnalyticsData: nil)

        await fulfillment(of: [expectation], timeout: 2.0)

        let captured = capturingTrackingEventsAPI.capturedEventData
        XCTAssertEqual(captured?.eventName, "paypal-web-payments:system-latency")
        XCTAssertEqual(captured?.presentationType, "browser")
        XCTAssertEqual(captured?.flow, "checkout")
        let startTime = try? XCTUnwrap(captured?.startTime)
        let endTime = try? XCTUnwrap(captured?.endTime)
        XCTAssertNotNil(startTime)
        XCTAssertNotNil(endTime)
        if let startTime, let endTime {
            XCTAssertGreaterThanOrEqual(endTime, startTime)
        }
    }

    func testSend_calledTwiceAfterSingleBegin_emitsOnce() async {
        let expectation = expectation(description: "system-latency event sent once")
        capturingTrackingEventsAPI.onSendEvent = { expectation.fulfill() }

        sut.begin(flow: .vault)
        sut.send(presentationType: .appSwitch, using: analyticsService, checkoutAnalyticsData: nil)
        // Second call in the same flow must be a no-op (measurement already consumed).
        sut.send(presentationType: .browser, using: analyticsService, checkoutAnalyticsData: nil)

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(capturingTrackingEventsAPI.sendCount, 1)
        XCTAssertEqual(capturingTrackingEventsAPI.capturedEventData?.presentationType, "app-switch")
        XCTAssertEqual(capturingTrackingEventsAPI.capturedEventData?.flow, "vault")
    }

    func testReset_afterBegin_preventsEmit() {
        sut.begin(flow: .checkout)
        sut.reset()
        sut.send(presentationType: .browser, using: analyticsService, checkoutAnalyticsData: nil)

        XCTAssertEqual(capturingTrackingEventsAPI.sendCount, 0)
        XCTAssertNil(capturingTrackingEventsAPI.capturedEventData)
    }
}
