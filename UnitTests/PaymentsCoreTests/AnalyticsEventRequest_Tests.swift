import XCTest
@testable import CorePayments

class AnalyticsEventRequest_Tests: XCTestCase {
    
    var fakeAnalyticsEventData: AnalyticsEventData!
    var sut: AnalyticsEventRequest!
    
    let currentTime = String(Date().timeIntervalSince1970 * 1000)
    let oneSecondLater = String((Date().timeIntervalSince1970 * 1000) + 999)
    
    override func setUp() {
        super.setUp()
        fakeAnalyticsEventData = AnalyticsEventData(
            environment: "fake-env",
            eventName: "fake-name",
            clientID: "fake-client-id",
            sessionID: "fake-session"
        )
        
        sut = try! AnalyticsEventRequest(eventData: fakeAnalyticsEventData)
    }

    func test_httpParameters() throws {
        let bodyData = sut.body
        let jsonBody = try? JSONSerialization.jsonObject(with: bodyData!) as? [String: [String: [String: Any]]]
            
        guard let eventParams = jsonBody?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }
        
        XCTAssertEqual(eventParams["app_id"] as? String, "com.apple.dt.xctest.tool")
        XCTAssertEqual(eventParams["app_name"] as? String, "xctest")
        XCTAssertTrue((eventParams["c_sdk_ver"] as! String).matches("^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
        XCTAssertTrue((eventParams["client_os"] as! String).matches("iOS \\d+\\.\\d+|iPadOS \\d+\\.\\d+"))
        XCTAssertEqual(eventParams["comp"] as? String, "ppcpmobilesdk")
        XCTAssertEqual(eventParams["device_manufacturer"] as? String, "Apple")
        XCTAssertEqual(eventParams["merchant_app_environment"] as? String, "fake-env")
        XCTAssertEqual(eventParams["event_name"] as? String, "fake-name")
        XCTAssertEqual(eventParams["event_source"] as? String, "mobile-native")
        XCTAssertTrue((eventParams["ios_package_manager"] as! String).matches("Carthage or Other|CocoaPods|Swift Package Manager"))
        XCTAssertEqual(eventParams["is_simulator"] as? Bool, true)
        XCTAssertNotNil(eventParams["mapv"] as? String) // Unable to specify bundle version number within test targets
        XCTAssertTrue((eventParams["mobile_device_model"] as! String).matches("iPhone\\d,\\d|x86_64|arm64"))
        XCTAssertEqual(eventParams["partner_client_id"] as! String, "fake-client-id")
        XCTAssertEqual(eventParams["platform"] as? String, "iOS")
        XCTAssertEqual(eventParams["session_id"] as? String, "fake-session")
        XCTAssertGreaterThanOrEqual(eventParams["t"] as! String, currentTime)
        XCTAssertLessThanOrEqual(eventParams["t"] as! String, oneSecondLater)
        XCTAssertEqual(eventParams["tenant_name"] as? String, "PayPal")
        
        XCTAssertEqual(sut.path, "v1/tracking/events")
        XCTAssertEqual(sut.method, HTTPMethod.post)
        XCTAssertEqual(sut.headers, [.contentType: "application/json"])
    }
    
    func testToURLRequest_overridesSandboxBaseURL() throws {
        let urlRequest = sut.toURLRequest(environment: .sandbox)
        XCTAssertEqual(urlRequest?.url?.absoluteString, "https://api.paypal.com/v1/tracking/events")
    }
}

extension String {
    
    func matches(_ regex: String) -> Bool {
        self.range(of: regex, options: .regularExpression) != nil
    }
}
