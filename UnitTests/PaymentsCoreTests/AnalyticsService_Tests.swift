import XCTest
@testable import PaymentsCore
@testable import TestShared

// swiftlint:disable force_unwrapping force_cast implicitly_unwrapped_optional
class AnalyticsService_Tests: XCTestCase {
    
    // MARK: - Helper properties
    
    var mockURLSession: MockURLSession!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = HTTPURLResponse(url: URL(string: "www.fake-url.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
        mockURLSession.cannedJSONData = ""
    }
    
    // MARK: - sendEvent()
    
    func testSendEvent_postsAnalyticsEventRequestType() async {
        let fakeConfig = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: fakeConfig)
        
        let analyticsService = AnalyticsService(http: mockHTTP)
        await analyticsService.sendEvent("fake-event")
        
        XCTAssert(mockHTTP.lastAPIRequest is AnalyticsEventRequest)
    }
    
    func testSendEvent_onMultipleClassInstances_postsSameSessionID() async {
        let firstFakeConfig = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let firstFakeHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: firstFakeConfig)
        
        let secondFakeConfig = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let secondFakeHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: secondFakeConfig)

        let firstAnalyticsService = AnalyticsService(http: firstFakeHTTP)
        let secondAnalyticsService = AnalyticsService(http: secondFakeHTTP)
        
        await firstAnalyticsService.sendEvent("fake-event-1")
        let firstSessionParams = firstFakeHTTP.lastPOSTParameters as! [String: [String: [String: Any]]]
        let firstSessionID = firstSessionParams["events"]!["event_params"]!["session_id"]! as! String
        
        await secondAnalyticsService.sendEvent("fake-event-2")
        let secondSessionParams = secondFakeHTTP.lastPOSTParameters as! [String: [String: [String: Any]]]
        let secondSessionID = secondSessionParams["events"]!["event_params"]!["session_id"]! as! String
        
        XCTAssertEqual(firstSessionID, secondSessionID)
    }
}
