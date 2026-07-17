import XCTest
@testable import CorePayments
@testable import TestShared

class AnalyticsService_Tests: XCTestCase {

    // MARK: - Helper properties

    var sut: AnalyticsService!
    var mockTrackingEventsAPI: MockTrackingEventsAPI!
    var coreConfig = CoreConfig(clientID: "some-client-id", environment: .sandbox, merchantID: "some-merchant-id")

    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
                
        mockTrackingEventsAPI = MockTrackingEventsAPI(coreConfig: coreConfig)
        sut = AnalyticsService(coreConfig: coreConfig, orderID: "some-order-id", trackingEventsAPI: mockTrackingEventsAPI)
    }

    // MARK: - sendEvent()
        
    func testSendEvent_sendsAppropriateAnalyticsEventData() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "some-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.clientID, "some-client-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.merchantID, "some-merchant-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.orderID, "some-order-id")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }
    
    func testSendEvent_whenLive_sendsAppropriateEnvName() async {
        let sut = AnalyticsService(
            coreConfig: CoreConfig(clientID: "some-client-id", environment: .live, merchantID: "some-mechant-id"),
            orderID: "some-order-id",
            trackingEventsAPI: mockTrackingEventsAPI
        )
        
        await sut.performEventRequest("some-event")
        
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.environment, "live")
    }
    
    func testSendEvent_whenSandbox_sendsAppropriateEnvName() async {
        await sut.performEventRequest("some-event")
        
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.environment, "sandbox")
    }
    
    func testSendEvent_whenAPIRequestFails_logsErrorToConsole() {
        // We currently have no way to validate our console logging
    }

    func testSendEvent_sendsNewAnalyticsFields() async {
        let appSwitchURL = URL(string: "https://example.com/app-switch")!
        let returnAppURL = URL(string: "https://example.com/return")!
        let cancelAppURL = URL(string: "https://example.com/cancel")!
        let fallbackSchemeURL = URL(string: "fake-scheme://fallback")!

        let checkoutAnalyticsData = PayPalCheckoutAnalyticsData()
        checkoutAnalyticsData.sessionCreationStartTime = 1_234_567_890
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

        await sut.performEventRequest(
            "some-event",
            correlationID: "fake-correlation-id",
            buttonType: "fake-button-type",
            errorDescription: "fake-error-description",
            checkoutAnalyticsData: checkoutAnalyticsData
        )

        let capturedData = mockTrackingEventsAPI.capturedAnalyticsEventData

        XCTAssertEqual(capturedData?.buttonType, "fake-button-type")
        XCTAssertEqual(capturedData?.errorDescription, "fake-error-description")
        XCTAssertEqual(capturedData?.appSwitchURL, appSwitchURL)
        XCTAssertEqual(capturedData?.appSwitchEligible, true)
        XCTAssertEqual(capturedData?.ineligibleReason, "fake-ineligible-reason")
        XCTAssertEqual(capturedData?.fallbackUrl, "fake-fallback-url")
        XCTAssertEqual(capturedData?.fallbackSchemeURL, fallbackSchemeURL)
        XCTAssertEqual(capturedData?.returnAppURL, returnAppURL)
        XCTAssertEqual(capturedData?.cancelAppURL, cancelAppURL)
        XCTAssertEqual(capturedData?.userAction, "CONTINUE")
        XCTAssertEqual(capturedData?.paypalNativeAppInstalled, true)
        XCTAssertEqual(capturedData?.isCachedSession, true)
        XCTAssertEqual(capturedData?.isVaultRequest, true)
        XCTAssertEqual(capturedData?.shopperSessionId, "fake-shopper-session-id")
        XCTAssertEqual(capturedData?.shopperSessionExpiration, "fake-shopper-session-expiration")
        XCTAssertEqual(capturedData?.startTime, 1_234_567_890)
    }

    func testSendEvent_withoutNewAnalyticsFields_sendsThemAsNil() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        let capturedData = mockTrackingEventsAPI.capturedAnalyticsEventData

        XCTAssertNil(capturedData?.bnCode)
        XCTAssertNil(capturedData?.appSwitchURL)
        XCTAssertNil(capturedData?.appSwitchEligible)
        XCTAssertNil(capturedData?.ineligibleReason)
        XCTAssertNil(capturedData?.fallbackUrl)
        XCTAssertNil(capturedData?.fallbackSchemeURL)
        XCTAssertNil(capturedData?.returnAppURL)
        XCTAssertNil(capturedData?.cancelAppURL)
        XCTAssertNil(capturedData?.userAction)
        XCTAssertNil(capturedData?.paypalNativeAppInstalled)
        XCTAssertNil(capturedData?.errorDescription)
        XCTAssertNil(capturedData?.isCachedSession)
        XCTAssertNil(capturedData?.isVaultRequest)
        XCTAssertNil(capturedData?.shopperSessionId)
        XCTAssertNil(capturedData?.shopperSessionExpiration)
        XCTAssertNil(capturedData?.startTime)
    }
}
