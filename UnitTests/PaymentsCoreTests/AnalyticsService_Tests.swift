import XCTest
@testable import CorePayments
@testable import TestShared

class AnalyticsService_Tests: XCTestCase {

    // MARK: - Helper properties

    var sut: AnalyticsService!
    var mockTrackingEventsAPI: MockTrackingEventsAPI!
    var coreConfig = CoreConfig(clientID: "some-client-id", environment: .sandbox, merchantID: "some-merchant-id")

    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
                
        mockTrackingEventsAPI = MockTrackingEventsAPI(coreConfig: coreConfig)
        sut = AnalyticsService(coreConfig: coreConfig, orderID: "some-order-id", trackingEventsAPI: mockTrackingEventsAPI)
    }

    // MARK: - sendEvent()

    func testSendEvent_dispatchesAnalyticsEvent() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)

        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "some-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }

    func testSendEvent_withBackgroundProtection_dispatchesAnalyticsEvent() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        let expectation = expectation(description: "background-protected analytics sent")
        mockTrackingEventsAPI.onSendEvent = { expectation.fulfill() }

        sut.sendEvent("bg-event", withBackgroundProtection: true)
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "bg-event")
    }

    func testPerformEventRequest_whenTaskCancelled_doesNotCallAPI() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        mockTrackingEventsAPI.sendEventDelay = 500_000_000

        let task = Task {
            await sut.performEventRequest("cancelled-event")
        }
        try? await Task.sleep(nanoseconds: 50_000_000)
        task.cancel()
        await task.value

        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData)
    }

    func testPerformEventRequest_whenAPIThrowsCancellationError_doesNotThrow() async {
        mockTrackingEventsAPI.stubError = CancellationError()

        await sut.performEventRequest("some-event")
    }
        
    func testSendEvent_sendsAppropriateAnalyticsEventData() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "some-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.clientID, "some-client-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.orderID, "some-order-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }
    
    func testSendEvent_whenLive_sendsAppropriateEnvName() async {
        let sut = AnalyticsService(
            coreConfig: CoreConfig(clientID: "some-client-id", environment: .live, merchantID: "some-mechant-id"),
            orderID: "some-order-id",
            trackingEventsAPI: mockTrackingEventsAPI
        )
        
        await sut.performEventRequest("some-event")
        
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.environment, "live")
    }
    
    func testSendEvent_whenSandbox_sendsAppropriateEnvName() async {
        await sut.performEventRequest("some-event")
        
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.environment, "sandbox")
    }
    
    func testSendEvent_whenAPIRequestFails_logsErrorToConsole() {
        // We currently have no way to validate our console logging
    }

    func testSendEvent_sendsNewAnalyticsFields() async {
        let appSwitchURL = URL(string: "https://example.com/app-switch")!

        await sut.performEventRequest(
            "some-event",
            correlationID: "fake-correlation-id",
            buttonType: "fake-button-type",
            appSwitchURL: appSwitchURL,
            errorDescription: "fake-error-description",
            isCachedSession: true,
            isVaultRequest: true,
            shopperSessionId: "fake-shopper-session-id",
            startTime: 1_234_567_890
        )

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.buttonType, "fake-button-type")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.appSwitchURL, appSwitchURL)
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.errorDescription, "fake-error-description")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.isCachedSession, true)
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.isVaultRequest, true)
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.shopperSessionId, "fake-shopper-session-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.startTime, 1_234_567_890)
    }

    func testSendEvent_withoutNewAnalyticsFields_sendsThemAsNil() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.appSwitchURL)
        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.errorDescription)
        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.isCachedSession)
        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.isVaultRequest)
        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.shopperSessionId)
        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData?.startTime)
    }
}
