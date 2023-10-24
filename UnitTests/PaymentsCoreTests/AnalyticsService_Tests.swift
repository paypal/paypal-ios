import XCTest
@testable import CorePayments
@testable import TestShared

class AnalyticsService_Tests: XCTestCase {

    // MARK: - Helper properties

    var sut: AnalyticsService!
    var mockTrackingEventsAPI: MockTrackingEventsAPI!
    var coreConfig = CoreConfig(clientID: "some-client-id", environment: .sandbox)

    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
                
        mockTrackingEventsAPI = MockTrackingEventsAPI(coreConfig: coreConfig)
        sut = AnalyticsService(coreConfig: coreConfig, orderID: "some-order-id", trackingEventsAPI: mockTrackingEventsAPI)
    }

    // MARK: - sendEvent()
        
    func testSendEvent_sendsAppropriateAnalyticsEventData() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "some-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.clientID, "some-client-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.orderID, "some-order-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }
    
    func testSendEvent_whenLive_sendsAppropriateEnvName() async {
        let sut = AnalyticsService(
            coreConfig: CoreConfig(clientID: "some-client-id", environment: .live),
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
}
