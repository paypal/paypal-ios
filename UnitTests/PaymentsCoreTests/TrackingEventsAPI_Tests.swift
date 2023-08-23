import Foundation
import XCTest
@testable import TestShared
@testable import CorePayments

class TrackingEventsAPI_Tests: XCTest {
    
    // MARK: - Helper Properties
    
    var sut: TrackingEventsAPI!
    var mockAPIClient: MockAPIClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockAPIClient = MockAPIClient(http: mockHTTP)
        sut = TrackingEventsAPI(coreConfig: coreConfig, apiClient: mockAPIClient)
    }
    
    // MARK: - sendEvent() REST

    func testSendEvent_alwaysUsesLiveConfig() {
        let sut = TrackingEventsAPI(coreConfig: coreConfig)
        XCTAssertEqual(sut.coreConfig.environment, .live)
    }
    
    func testSendEvent_constructsRESTRequestForV1Tracking() async throws {
        let fakeAnalyticsEventData = AnalyticsEventData(
            environment: "my-env",
            eventName: "my-event-name",
            clientID: "my-id",
            orderID: "my-order"
        )
        _ = try await sut.sendEvent(with: fakeAnalyticsEventData)
        
        XCTAssertEqual(mockAPIClient.capturedRESTRequest?.path, "v1/tracking/events")
        XCTAssertEqual(mockAPIClient.capturedRESTRequest?.method, .post)
        XCTAssertNil(mockAPIClient.capturedRESTRequest?.queryParameters)
        
        let postData = mockAPIClient.capturedRESTRequest?.postParameters as! AnalyticsEventData
        XCTAssertEqual(postData.environment, "my-env")
        XCTAssertEqual(postData.eventName, "my-event-name")
        XCTAssertEqual(postData.clientID, "my-id")
        XCTAssertEqual(postData.orderID, "my-order")
    }
}
