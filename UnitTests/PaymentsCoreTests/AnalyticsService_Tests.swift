import XCTest
@testable import PaymentsCore
@testable import TestShared

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
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
        await analyticsService.sendEvent("fake-event")

        XCTAssert(mockHTTP.lastAPIRequest is AnalyticsEventRequest)
    }
    
    // MARK: - sharedInstance()

    func testSharedInstance_withDifferentAccessToken_postsUniqueSessionID() async {
        // Construct 1st CoreConfig
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        var analyticsService = AnalyticsService.sharedInstance(http: mockHTTP1)
        
        // Capture sessionID
        let sessionID1 = analyticsService.sessionID
        
        // Construct 2nd CoreConfig
        let config2 = CoreConfig(accessToken: "fake-token-2", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)
        analyticsService = AnalyticsService.sharedInstance(http: mockHTTP2)
        
        // Capture sessionID
        let sessionID2 = analyticsService.sessionID

        XCTAssertNotEqual(sessionID1, sessionID2)
    }
    
    func testSharedInstance_withSameAccessToken_postsSameSessionID() async {
        // Construct 1st CoreConfig
        let config1 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP1 = MockHTTP(urlSession: mockURLSession, coreConfig: config1)
        var analyticsService = AnalyticsService.sharedInstance(http: mockHTTP1)
        
        // Capture sessionID
        let sessionID1 = analyticsService.sessionID
        
        // Construct 2nd CoreConfig
        let config2 = CoreConfig(accessToken: "fake-token-1", environment: .sandbox)
        let mockHTTP2 = MockHTTP(urlSession: mockURLSession, coreConfig: config2)
        analyticsService = AnalyticsService.sharedInstance(http: mockHTTP2)
        
        // Capture sessionID
        let sessionID2 = analyticsService.sessionID

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
