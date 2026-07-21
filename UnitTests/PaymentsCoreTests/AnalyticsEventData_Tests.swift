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

    func testEncode_withNoOptionalAnalyticsFields_omitsThemFromJSON() throws {
        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        XCTAssertFalse(eventParams.keys.contains("app_switch_url"))
        XCTAssertFalse(eventParams.keys.contains("error_description"))
        XCTAssertFalse(eventParams.keys.contains("is_cached_session"))
        XCTAssertFalse(eventParams.keys.contains("is_vault_request"))
        XCTAssertFalse(eventParams.keys.contains("shopper_session_id"))
        XCTAssertFalse(eventParams.keys.contains("start_time"))
        XCTAssertFalse(eventParams.keys.contains("end_time"))
        XCTAssertFalse(eventParams.keys.contains("endpoint"))
        XCTAssertFalse(eventParams.keys.contains("presentation_type"))
        XCTAssertFalse(eventParams.keys.contains("flow"))
    }

    func testEncode_withNewAnalyticsFields_properlyFormatsJSON() throws {
        let appSwitchURL = URL(string: "https://example.com/app-switch")!

        sut = AnalyticsEventData(
            environment: "fake-env",
            eventName: "fake-name",
            clientID: "fake-client-id",
            orderID: "fake-order",
            correlationID: "fake-correlation-id",
            setupToken: "fake-setup-token",
            buttonType: "fake-button-type",
            appSwitchURL: appSwitchURL,
            errorDescription: "fake-error-description",
            isCachedSession: true,
            isVaultRequest: true,
            shopperSessionId: "fake-shopper-session-id",
            startTime: 1_234_567_890,
            endTime: 1_234_567_999,
            endpoint: "/v2/checkout/orders",
            presentationType: "browser",
            flow: "checkout"
        )

        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        XCTAssertEqual(eventParams["button_type"] as? String, "fake-button-type")
        XCTAssertEqual(eventParams["app_switch_url"] as? String, appSwitchURL.absoluteString)
        XCTAssertEqual(eventParams["error_description"] as? String, "fake-error-description")
        XCTAssertEqual(eventParams["is_cached_session"] as? Bool, true)
        XCTAssertEqual(eventParams["is_vault_request"] as? Bool, true)
        XCTAssertEqual(eventParams["shopper_session_id"] as? String, "fake-shopper-session-id")
        XCTAssertEqual(eventParams["start_time"] as? Int64, 1_234_567_890)
        XCTAssertEqual(eventParams["end_time"] as? Int64, 1_234_567_999)
        XCTAssertEqual(eventParams["endpoint"] as? String, "/v2/checkout/orders")
        XCTAssertEqual(eventParams["presentation_type"] as? String, "browser")
        XCTAssertEqual(eventParams["flow"] as? String, "checkout")
    }
}

extension String {
    
    func matches(_ regex: String) -> Bool {
        self.range(of: regex, options: .regularExpression) != nil
    }
}
