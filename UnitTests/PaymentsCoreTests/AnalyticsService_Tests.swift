import XCTest
@testable import CorePayments
@testable import TestShared

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional force_cast
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

        let analyticsService = AnalyticsService.sharedInstance(http: mockHTTP)
        await analyticsService.sendEvent(name: "fake-event", clientID: "fake-client-id")

        XCTAssert(mockHTTP.lastAPIRequest is AnalyticsEventRequest)
    }
    
    func testSendEvent_whenLive_sendsProperTag() async {
        let fakeConfig = CoreConfig(accessToken: "fake-token-1", environment: .live)
        let mockHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: fakeConfig)

        let analyticsService = AnalyticsService.sharedInstance(http: mockHTTP)
        await analyticsService.sendEvent(name: "fake-event", clientID: "fake-client-id")
        
        guard let eventParams = (mockHTTP.lastPOSTParameters?["events"] as! [String: [String: Any]])["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }
        
        XCTAssertEqual(eventParams["merchant_app_environment"] as? String, "live")
    }
    
    func testSendEvent_whenSandbox_sendsProperTag() async {
        let fakeConfig = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: fakeConfig)

        let analyticsService = AnalyticsService.sharedInstance(http: mockHTTP)
        await analyticsService.sendEvent(name: "fake-event", clientID: "fake-client-id")
        
        guard let eventParams = (mockHTTP.lastPOSTParameters?["events"] as! [String: [String: Any]])["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }
        
        XCTAssertEqual(eventParams["merchant_app_environment"] as? String, "sandbox")
    }
    
    // MARK: - sharedInstance()

    func testSharedInstance_withDifferentAccessToken_postsUniqueSessionID() async {
        // Construct 1st CoreConfig
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        var analyticsService = AnalyticsService.sharedInstance(http: mockHTTP1)
        
        // Send 1st event
        await analyticsService.sendEvent(name: "fake-event-1", clientID: "fake-client-id")
        
        // Capture sessionID
        let postParams1 = mockHTTP1.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID1 = postParams1["events"]!["event_params"]!["session_id"]! as! String
        
        // Construct 2nd CoreConfig
        let config2 = CoreConfig(accessToken: "fake-token-2", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)
        analyticsService = AnalyticsService.sharedInstance(http: mockHTTP2)
        
        // Send 2nd event
        await analyticsService.sendEvent(name: "fake-event-2", clientID: "fake-client-id")
        
        // Capture sessionID
        let postParams2 = mockHTTP2.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID2 = postParams2["events"]!["event_params"]!["session_id"]! as! String

        XCTAssertNotEqual(sessionID1, sessionID2)
    }
    
    func testSharedInstance_withSameAccessToken_postsSameSessionID() async {
        // Construct 1st CoreConfig
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        var analyticsService = AnalyticsService.sharedInstance(http: mockHTTP1)
        
        // Send 1st event
        await analyticsService.sendEvent(name: "fake-event-1", clientID: "fake-client-id")
        
        // Capture sessionID
        let postParams1 = mockHTTP1.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID1 = postParams1["events"]!["event_params"]!["session_id"]! as! String
        
        // Construct 2nd CoreConfig
        let config2 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)
        analyticsService = AnalyticsService.sharedInstance(http: mockHTTP2)
        
        // Send 2nd event
        await analyticsService.sendEvent(name: "fake-event-2", clientID: "fake-client-id")
        
        // Capture sessionID
        let postParams2 = mockHTTP2.lastPOSTParameters as! [String: [String: [String: Any]]]
        let sessionID2 = postParams2["events"]!["event_params"]!["session_id"]! as! String

        XCTAssertEqual(sessionID1, sessionID2)
    }
        
    func testSharedInstance_returnsSingletonInstance() {
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        let analyticsService1 = AnalyticsService.sharedInstance(http: mockHTTP1)
        
        let config2 = CoreConfig(accessToken: "fake-token-2", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)
        let analyticsService2 = AnalyticsService.sharedInstance(http: mockHTTP2)
        
        XCTAssertTrue(analyticsService1 === analyticsService2)
    }
}
// swiftlint:enable force_unwrapping implicitly_unwrapped_optional force_cast
