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
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        
        let config2 = CoreConfig(accessToken: "fake-token-2", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)

        let analyticsService1 = AnalyticsService(http: mockHTTP1)
        let analyticsService2 = AnalyticsService(http: mockHTTP2)
        
        await analyticsService1.sendEvent("fake-event-1")
        let postParams1 = mockHTTP1.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID1 = postParams1["events"]!["event_params"]!["session_id"]! as! String
        
        await analyticsService2.sendEvent("fake-event-2")
        let postParam2 = mockHTTP2.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID2 = postParam2["events"]!["event_params"]!["session_id"]! as! String
        
        XCTAssertEqual(sessionID1, sessionID2)
    }
}
