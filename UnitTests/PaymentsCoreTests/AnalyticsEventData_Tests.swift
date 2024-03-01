import XCTest
@testable import CorePayments

class AnalyticsEventData_Tests: XCTestCase {
    
    var sut: AnalyticsEventData!
    
    let currentTime = String(Date().timeIntervalSince1970 * 1000)
    let oneSecondLater = String((Date().timeIntervalSince1970 * 1000) + 999)
    
    override func setUp() {
        super.setUp()
        sut = AnalyticsEventData(
            environment: "fake-env",
            eventName: "fake-name",
            clientID: "fake-client-id",
            orderID: "fake-order",
            correlationID: "fake-correlation-id",
            setupToken: "fake-setup-token"
        )
    }

    func testEncode_properlyFormatsJSON() throws {
        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]
            
        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }
        
        XCTAssertEqual(eventParams["app_id"] as? String, "com.apple.dt.xctest.tool")
        XCTAssertEqual(eventParams["app_name"] as? String, "xctest")
        XCTAssertTrue((eventParams["c_sdk_ver"] as! String).matches("^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
        XCTAssertTrue((eventParams["client_os"] as! String).matches("iOS \\d+\\.\\d+|iPadOS \\d+\\.\\d+"))
        XCTAssertEqual(eventParams["comp"] as? String, "ppcpclientsdk")
        XCTAssertEqual(eventParams["correlation_id"] as! String, "fake-correlation-id")
        XCTAssertEqual(eventParams["device_manufacturer"] as? String, "Apple")
        XCTAssertEqual(eventParams["merchant_sdk_env"] as? String, "fake-env")
        XCTAssertEqual(eventParams["event_name"] as? String, "fake-name")
        XCTAssertEqual(eventParams["event_source"] as? String, "mobile-native")
        XCTAssertTrue((eventParams["ios_package_manager"] as! String).matches("Carthage or Other|CocoaPods|Swift Package Manager"))
        XCTAssertEqual(eventParams["is_simulator"] as? Bool, true)
        XCTAssertNotNil(eventParams["mapv"] as? String) // Unable to specify bundle version number within test targets
        XCTAssertTrue((eventParams["mobile_device_model"] as! String).matches("iPhone\\d,\\d|x86_64|arm64"))
        XCTAssertEqual(eventParams["partner_client_id"] as! String, "fake-client-id")
        XCTAssertEqual(eventParams["platform"] as? String, "iOS")
        XCTAssertEqual(eventParams["order_id"] as? String, "fake-order")
        XCTAssertGreaterThanOrEqual(eventParams["t"] as! String, currentTime)
        XCTAssertLessThanOrEqual(eventParams["t"] as! String, oneSecondLater)
        XCTAssertEqual(eventParams["tenant_name"] as? String, "PayPal")
        XCTAssertEqual(eventParams["vault_setup_token"] as? String, "fake-setup-token")
    }
}

extension String {
    
    func matches(_ regex: String) -> Bool {
        self.range(of: regex, options: .regularExpression) != nil
    }
}
