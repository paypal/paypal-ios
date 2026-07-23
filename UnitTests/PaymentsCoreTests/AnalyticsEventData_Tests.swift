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
            merchantID: "fake-merchant-id",
            bnCode: nil,
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
        XCTAssertEqual(eventParams["merchant_id"] as? String, "fake-merchant-id")
        XCTAssertEqual(eventParams["platform"] as? String, "iOS")
        XCTAssertEqual(eventParams["order_id"] as? String, "fake-order")
        XCTAssertGreaterThanOrEqual(eventParams["t"] as! String, currentTime)
        XCTAssertLessThanOrEqual(eventParams["t"] as! String, oneSecondLater)
        XCTAssertEqual(eventParams["tenant_name"] as? String, "PayPal")
        XCTAssertEqual(eventParams["vault_setup_token"] as? String, "fake-setup-token")
    }

    func testEncode_withNoNewAnalyticsFields_encodesThemAsNull() throws {
        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        let newFieldKeys = [
            "app_switch_eligible",
            "app_switch_url",
            "bn_code",
            "cancel_app_url",
            "end_time",
            "endpoint",
            "error_description",
            "fallback_scheme_url",
            "fallback_url",
            "flow",
            "ineligible_reason",
            "is_cached_session",
            "is_vault",
            "paypal_installed",
            "presentation_type",
            "return_app_url",
            "shopper_session_expiration",
            "shopper_session_id",
            "start_time",
            "user_action"
        ]

        for key in newFieldKeys {
            XCTAssertTrue(eventParams.keys.contains(key), "Expected `event_params` to contain key `\(key)`.")
            XCTAssertTrue(eventParams[key] is NSNull, "Expected `\(key)` to encode as null.")
        }
    }

    func testEncode_withNewAnalyticsFields_properlyFormatsJSON() throws {
        let appSwitchURL = URL(string: "https://example.com/app-switch")!
        let returnAppURL = URL(string: "https://example.com/return")!
        let cancelAppURL = URL(string: "https://example.com/cancel")!
        let fallbackSchemeURL = URL(string: "fake-scheme://fallback")!

        let checkoutAnalyticsData = PayPalCheckoutAnalyticsData()
        checkoutAnalyticsData.isCachedSession = true
        checkoutAnalyticsData.shopperSessionID = "fake-shopper-session-id"
        checkoutAnalyticsData.shopperSessionExpiration = "fake-shopper-session-expiration"
        checkoutAnalyticsData.appSwitchURL = appSwitchURL
        checkoutAnalyticsData.appSwitchEligible = true
        checkoutAnalyticsData.ineligibleReason = "fake-ineligible-reason"
        checkoutAnalyticsData.fallbackUrl = "fake-fallback-url"
        checkoutAnalyticsData.isVaultRequest = true
        checkoutAnalyticsData.userAction = "CONTINUE"
        checkoutAnalyticsData.paypalNativeAppInstalled = true
        checkoutAnalyticsData.returnAppURL = returnAppURL
        checkoutAnalyticsData.cancelAppURL = cancelAppURL
        checkoutAnalyticsData.fallbackSchemeURL = fallbackSchemeURL

        sut = AnalyticsEventData(
            environment: "fake-env",
            eventName: "fake-name",
            clientID: "fake-client-id",
            merchantID: "fake-merchant-id",
            bnCode: "fake-bn-code",
            orderID: "fake-order",
            correlationID: "fake-correlation-id",
            setupToken: "fake-setup-token",
            buttonType: "fake-button-type",
            errorDescription: "fake-error-description",
            checkoutAnalyticsData: checkoutAnalyticsData
        )

        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        XCTAssertEqual(eventParams["button_type"] as? String, "fake-button-type")
        XCTAssertEqual(eventParams["bn_code"] as? String, "fake-bn-code")
        XCTAssertEqual(eventParams["app_switch_url"] as? String, appSwitchURL.absoluteString)
        XCTAssertEqual(eventParams["app_switch_eligible"] as? Bool, true)
        XCTAssertEqual(eventParams["ineligible_reason"] as? String, "fake-ineligible-reason")
        XCTAssertEqual(eventParams["fallback_url"] as? String, "fake-fallback-url")
        XCTAssertEqual(eventParams["fallback_scheme_url"] as? String, fallbackSchemeURL.absoluteString)
        XCTAssertEqual(eventParams["return_app_url"] as? String, returnAppURL.absoluteString)
        XCTAssertEqual(eventParams["cancel_app_url"] as? String, cancelAppURL.absoluteString)
        XCTAssertEqual(eventParams["user_action"] as? String, "CONTINUE")
        XCTAssertEqual(eventParams["paypal_installed"] as? Bool, true)
        XCTAssertEqual(eventParams["error_description"] as? String, "fake-error-description")
        XCTAssertEqual(eventParams["is_cached_session"] as? Bool, true)
        XCTAssertEqual(eventParams["is_vault"] as? Bool, true)
        XCTAssertEqual(eventParams["shopper_session_id"] as? String, "fake-shopper-session-id")
        XCTAssertEqual(eventParams["shopper_session_expiration"] as? String, "fake-shopper-session-expiration")
    }

    func testEncode_withLatencyFields_properlyFormatsJSON() throws {
        sut = AnalyticsEventData(
            environment: "fake-env",
            eventName: "paypal-web-payments:api-request-latency",
            clientID: "fake-client-id",
            merchantID: "fake-merchant-id",
            bnCode: nil,
            orderID: nil,
            correlationID: nil,
            setupToken: nil,
            startTime: 1_700_000_000_000,
            endTime: 1_700_000_000_250,
            endpoint: "/graphql/createShopperSessionWithAppSwitchEligibility"
        )

        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        XCTAssertEqual((eventParams["start_time"] as? NSNumber)?.int64Value, 1_700_000_000_000)
        XCTAssertEqual((eventParams["end_time"] as? NSNumber)?.int64Value, 1_700_000_000_250)
        XCTAssertEqual(eventParams["endpoint"] as? String, "/graphql/createShopperSessionWithAppSwitchEligibility")
    }

    func testEncode_withSystemLatencyFields_properlyFormatsJSON() throws {
        sut = AnalyticsEventData(
            environment: "fake-env",
            eventName: "paypal-web-payments:system-latency",
            clientID: "fake-client-id",
            merchantID: "fake-merchant-id",
            bnCode: nil,
            orderID: "fake-order",
            correlationID: nil,
            setupToken: nil,
            startTime: 1_700_000_000_000,
            endTime: 1_700_000_000_500,
            presentationType: "app-switch",
            flow: "checkout"
        )

        let data = try JSONEncoder().encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: Any]]]

        guard let eventParams = json?["events"]?["event_params"] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }

        XCTAssertEqual((eventParams["start_time"] as? NSNumber)?.int64Value, 1_700_000_000_000)
        XCTAssertEqual((eventParams["end_time"] as? NSNumber)?.int64Value, 1_700_000_000_500)
        XCTAssertEqual(eventParams["presentation_type"] as? String, "app-switch")
        XCTAssertEqual(eventParams["flow"] as? String, "checkout")
    }
}

extension String {
    
    func matches(_ regex: String) -> Bool {
        self.range(of: regex, options: .regularExpression) != nil
    }
}
