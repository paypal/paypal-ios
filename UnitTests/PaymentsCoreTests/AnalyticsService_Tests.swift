import XCTest
@testable import CorePayments
@testable import TestShared

class AnalyticsService_Tests: XCTestCase {

    // MARK: - Helper properties

    var mockURLSession: MockURLSession!
    var sut: AnalyticsService!
    var mockHTTP: MockHTTP!
    var coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = HTTPURLResponse(url: URL(string: "www.fake-url.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
        mockURLSession.cannedJSONData = """
            { "client_id": "fake-client-id" }
        """
        
        mockHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: coreConfig)
        
        sut = AnalyticsService(coreConfig: coreConfig, orderID: "fake-order-id", http: mockHTTP)
    }

    // MARK: - sendEvent()

    func testSendEvent_whenClientID_postsAnalyticsEventRequestType() async {
        await sut.performEventRequest("fake-event")
        
        XCTAssert(mockHTTP.lastAPIRequest is AnalyticsEventRequest)
    }
    
    func testSendEvent_whenLive_sendsProperTag() async {
        let coreConfig = CoreConfig(clientID: "fake-token", environment: .live)
        let mockHTTP = MockHTTP(urlSession: mockURLSession, coreConfig: coreConfig)
        let sut = AnalyticsService(coreConfig: coreConfig, orderID: "fake-orderID", http: mockHTTP)
        
        await sut.performEventRequest("fake-event")
        
        guard let env = parsePostParam(from: mockHTTP.lastPOSTParameters, forKey: "merchant_sdk_env") else {
            XCTFail("JSON body missing `merchant_sdk_env` key.")
            return
        }
        
        XCTAssertEqual(env, "live")
    }
    
    func testSendEvent_whenSandbox_sendsProperTag() async {
        await sut.performEventRequest("fake-event")
        
        guard let env = parsePostParam(from: mockHTTP.lastPOSTParameters, forKey: "merchant_sdk_env") else {
            XCTFail("JSON body missing `merchant_sdk_env` key.")
            return
        }
        
        XCTAssertEqual(env, "sandbox")
    }
    
    func testSendEvent_addsMetadataParams() async {
        await sut.performEventRequest("fake-event")
        
        guard let eventName = parsePostParam(from: mockHTTP.lastPOSTParameters, forKey: "event_name") else {
            XCTFail("JSON body missing `event_name` key.")
            return
        }
        
        guard let clientID = parsePostParam(from: mockHTTP.lastPOSTParameters, forKey: "partner_client_id") else {
            XCTFail("JSON body missing `partner_client_id` key.")
            return
        }
        
        guard let orderID = parsePostParam(from: mockHTTP.lastPOSTParameters, forKey: "order_id") else {
            XCTFail("JSON body missing `order_id` key.")
            return
        }
        
        XCTAssertEqual(eventName, "fake-event")
        XCTAssertEqual(clientID, "fake-client-id")
        XCTAssertEqual(orderID, "fake-order-id")
    }
    
    // MARK: - Helpers
    
    private func parsePostParam(from postParameters: [String: Any]?, forKey key: String) -> String? {
        let topLevelEvent = postParameters?["events"] as? [String: Any]
        let eventParams = topLevelEvent?["event_params"] as? [String: Any]
        return eventParams?[key] as? String
    }
}
