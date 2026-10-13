// This file also holds the `AnalyticsEventQueue` tests and their test doubles. The Xcode project references source
// files explicitly, so keeping them here avoids having to add a new file to the test target.
// swiftlint:disable file_length

import XCTest
import UIKit
@testable import CorePayments
@testable import TestShared

class AnalyticsService_Tests: XCTestCase {

    // MARK: - Helper properties

    var sut: AnalyticsService!
    var mockTrackingEventsAPI: MockTrackingEventsAPI!
    var fakeBackgroundTaskManager: FakeBackgroundTaskManager!
    var eventQueue: AnalyticsEventQueue!
    var coreConfig = CoreConfig(clientID: "some-client-id", environment: .sandbox, merchantID: "some-merchant-id")

    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
                
        mockTrackingEventsAPI = MockTrackingEventsAPI()
        fakeBackgroundTaskManager = FakeBackgroundTaskManager()
        eventQueue = AnalyticsEventQueue(backgroundTaskManager: fakeBackgroundTaskManager)
        sut = AnalyticsService(
            coreConfig: coreConfig,
            orderID: "some-order-id",
            trackingEventsAPI: mockTrackingEventsAPI,
            eventQueue: eventQueue
        )
    }

    // MARK: - sendEvent()

    func testSendEvent_dispatchesAnalyticsEvent() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)

        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "some-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }

    func testSendEvent_enqueuesAndDispatchesAnalyticsEvent() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        let expectation = expectation(description: "queued analytics sent")
        mockTrackingEventsAPI.onSendEvent = { expectation.fulfill() }

        sut.sendEvent("queued-event", correlationID: "fake-correlation-id")
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.eventName, "queued-event")
        XCTAssertEqual(mockTrackingEventsAPI.capturedAnalyticsEventData?.correlationID, "fake-correlation-id")
    }

    func testPerformEventRequest_whenTaskCancelled_doesNotCallAPI() async {
        mockTrackingEventsAPI.stubHTTPResponse = HTTPResponse(status: 200, body: nil)
        mockTrackingEventsAPI.sendEventDelay = 500_000_000

        let task = Task {
            await sut.performEventRequest("cancelled-event")
        }
        try? await Task.sleep(nanoseconds: 50_000_000)
        task.cancel()
        await task.value

        XCTAssertNil(mockTrackingEventsAPI.capturedAnalyticsEventData)
    }

    func testPerformEventRequest_whenAPIThrowsCancellationError_doesNotThrow() async {
        mockTrackingEventsAPI.stubError = CancellationError()

        await sut.performEventRequest("some-event")
    }
        
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
    
    // MARK: - makeEventData()

    func testMakeEventData_capturesCheckoutAnalyticsDataAtTimeOfCall() {
        let launchURL = URL(string: "https://sandbox.paypal.com/app-switch")!
        let returnURL = URL(string: "https://merchant.example.com/return")!

        var checkoutAnalyticsData = PayPalCheckoutAnalyticsData()
        checkoutAnalyticsData.url = launchURL

        let eventData = sut.makeEventData("app-switch:started", checkoutAnalyticsData: checkoutAnalyticsData)

        // Simulates `handleReturnURL` overwriting the URL after the event was created
        checkoutAnalyticsData.url = returnURL

        XCTAssertEqual(eventData.url, launchURL)
    }

    func testMakeEventData_stampsTimestampAtTimeOfCall() {
        let before = Date().timeIntervalSince1970 * 1000

        let eventData = sut.makeEventData("some-event")

        let after = Date().timeIntervalSince1970 * 1000
        let timestamp = Double(eventData.timestamp)

        XCTAssertNotNil(timestamp)
        XCTAssertGreaterThanOrEqual(timestamp ?? 0, before)
        XCTAssertLessThanOrEqual(timestamp ?? .infinity, after)
    }

    func testMakeEventData_includesOrderIDEnvironmentAndClientConfig() {
        let eventData = sut.makeEventData("some-event", correlationID: "fake-correlation-id")

        XCTAssertEqual(eventData.eventName, "some-event")
        XCTAssertEqual(eventData.orderID, "some-order-id")
        XCTAssertEqual(eventData.environment, "sandbox")
        XCTAssertEqual(eventData.clientID, "some-client-id")
        XCTAssertEqual(eventData.merchantID, "some-merchant-id")
        XCTAssertEqual(eventData.correlationID, "fake-correlation-id")
    }

    // MARK: - Delivery

    func testSendEvent_whenAPIRequestFails_logsErrorToConsole() {
        // We currently have no way to validate our console logging
    }

    func testSendEvent_sendsNewAnalyticsFields() async {
        let url = URL(string: "https://example.com/app-switch")!
        let returnAppURL = URL(string: "https://example.com/return")!
        let cancelAppURL = URL(string: "https://example.com/cancel")!
        let fallbackSchemeURL = URL(string: "fake-scheme://fallback")!

        var checkoutAnalyticsData = PayPalCheckoutAnalyticsData()
        checkoutAnalyticsData.isCachedSession = true
        checkoutAnalyticsData.shopperSessionID = "fake-shopper-session-id"
        checkoutAnalyticsData.shopperSessionExpiration = "fake-shopper-session-expiration"
        checkoutAnalyticsData.url = url
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
        XCTAssertEqual(capturedData?.url, url)
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
    }

    func testSendEvent_forwardsLatencyFieldsToAnalyticsEventData() async {
        await sut.performEventRequest(
            "paypal-payments:api-request-latency",
            startTime: 1_700_000_000_000,
            endTime: 1_700_000_000_250,
            endpoint: "/graphql/createShopperSessionWithAppSwitchEligibility"
        )

        let capturedData = mockTrackingEventsAPI.capturedAnalyticsEventData

        XCTAssertEqual(capturedData?.eventName, "paypal-payments:api-request-latency")
        XCTAssertEqual(capturedData?.startTime, 1_700_000_000_000)
        XCTAssertEqual(capturedData?.endTime, 1_700_000_000_250)
        XCTAssertEqual(capturedData?.endpoint, "/graphql/createShopperSessionWithAppSwitchEligibility")
    }

    func testSendEvent_forwardsSystemLatencyFieldsToAnalyticsEventData() async {
        await sut.performEventRequest(
            "paypal-payments:system-latency",
            startTime: 1_700_000_000_000,
            endTime: 1_700_000_000_500,
            presentationType: "browser",
            flow: "vault"
        )

        let capturedData = mockTrackingEventsAPI.capturedAnalyticsEventData

        XCTAssertEqual(capturedData?.eventName, "paypal-payments:system-latency")
        XCTAssertEqual(capturedData?.startTime, 1_700_000_000_000)
        XCTAssertEqual(capturedData?.endTime, 1_700_000_000_500)
        XCTAssertEqual(capturedData?.presentationType, "browser")
        XCTAssertEqual(capturedData?.flow, "vault")
    }

    func testSendEvent_withoutNewAnalyticsFields_sendsThemAsNil() async {
        await sut.performEventRequest("some-event", correlationID: "fake-correlation-id")

        let capturedData = mockTrackingEventsAPI.capturedAnalyticsEventData

        XCTAssertNil(capturedData?.startTime)
        XCTAssertNil(capturedData?.endTime)
        XCTAssertNil(capturedData?.endpoint)
        XCTAssertNil(capturedData?.presentationType)
        XCTAssertNil(capturedData?.flow)
        XCTAssertNil(capturedData?.bnCode)
        XCTAssertNil(capturedData?.url)
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
    }
}

// MARK: - AnalyticsEventQueue Tests

class AnalyticsEventQueue_Tests: XCTestCase {

    // MARK: - Helper properties

    var recordingAPI: RecordingTrackingEventsAPI!
    var fakeBackgroundTaskManager: FakeBackgroundTaskManager!
    var sut: AnalyticsEventQueue!
    let coreConfig = CoreConfig(clientID: "some-client-id", environment: .sandbox, merchantID: "some-merchant-id")

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        recordingAPI = RecordingTrackingEventsAPI()
        fakeBackgroundTaskManager = FakeBackgroundTaskManager()
        sut = AnalyticsEventQueue(backgroundTaskManager: fakeBackgroundTaskManager)
    }

    private func makeService(queue: AnalyticsEventQueue? = nil) -> AnalyticsService {
        AnalyticsService(
            coreConfig: coreConfig,
            orderID: "some-order-id",
            trackingEventsAPI: recordingAPI,
            eventQueue: queue ?? sut
        )
    }

    // MARK: - Ordering

    func testEnqueue_sendsEventsInTheOrderTheyWereFired() async {
        // If events were sent concurrently, the delayed first event would be the last to arrive.
        recordingAPI.delays["first"] = 200_000_000
        let delivered = expectation(description: "all events delivered")
        delivered.expectedFulfillmentCount = 3
        recordingAPI.onEventSent = { delivered.fulfill() }
        let service = makeService()

        service.sendEvent("first")
        service.sendEvent("second")
        service.sendEvent("third")
        await fulfillment(of: [delivered], timeout: 5.0)

        XCTAssertEqual(recordingAPI.sentEventNames, ["first", "second", "third"])
    }

    func testEnqueue_acrossServiceInstances_sendsEventsInTheOrderTheyWereFired() async {
        recordingAPI.delays["from-first-service"] = 200_000_000
        let delivered = expectation(description: "all events delivered")
        delivered.expectedFulfillmentCount = 2
        recordingAPI.onEventSent = { delivered.fulfill() }

        makeService().sendEvent("from-first-service")
        makeService().sendEvent("from-second-service")
        await fulfillment(of: [delivered], timeout: 5.0)

        XCTAssertEqual(recordingAPI.sentEventNames, ["from-first-service", "from-second-service"])
    }

    func testEnqueue_whenAnEventFails_stillSendsTheRemainingEvents() async {
        recordingAPI.failingEventNames = ["failing"]
        let delivered = expectation(description: "remaining events delivered")
        delivered.expectedFulfillmentCount = 2
        recordingAPI.onEventSent = { delivered.fulfill() }
        let service = makeService()

        service.sendEvent("first")
        service.sendEvent("failing")
        service.sendEvent("third")
        await fulfillment(of: [delivered], timeout: 5.0)

        XCTAssertEqual(recordingAPI.sentEventNames, ["first", "third"])
    }

    func testEnqueue_whenARequestExceedsTheTimeout_movesOnToTheNextEvent() async {
        let shortTimeoutQueue = AnalyticsEventQueue(backgroundTaskManager: fakeBackgroundTaskManager, requestTimeout: 0.1)
        recordingAPI.delays["slow"] = 10_000_000_000
        let delivered = expectation(description: "fast event delivered")
        recordingAPI.onEventSent = { delivered.fulfill() }
        let service = makeService(queue: shortTimeoutQueue)

        service.sendEvent("slow")
        service.sendEvent("fast")
        await fulfillment(of: [delivered], timeout: 5.0)

        XCTAssertEqual(recordingAPI.sentEventNames, ["fast"])
    }

    // MARK: - Event contents

    func testEnqueue_whenDeliveryIsDelayed_keepsStateAndTimestampFromTimeOfCall() async {
        let launchURL = URL(string: "https://sandbox.paypal.com/app-switch")!
        let returnURL = URL(string: "https://merchant.example.com/return")!

        // Holds the queue so the event under test is sent well after it was fired.
        recordingAPI.delays["blocker"] = 300_000_000
        let delivered = expectation(description: "both events delivered")
        delivered.expectedFulfillmentCount = 2
        recordingAPI.onEventSent = { delivered.fulfill() }
        let service = makeService()

        var checkoutAnalyticsData = PayPalCheckoutAnalyticsData()
        checkoutAnalyticsData.url = launchURL

        service.sendEvent("blocker")
        let before = Date().timeIntervalSince1970 * 1000
        service.sendEvent("app-switch:started", checkoutAnalyticsData: checkoutAnalyticsData)
        let after = Date().timeIntervalSince1970 * 1000
        // Simulates `handleReturnURL` overwriting the URL before the queued event is sent
        checkoutAnalyticsData.url = returnURL

        await fulfillment(of: [delivered], timeout: 5.0)

        let event = recordingAPI.sentEvents.first { $0.eventName == "app-switch:started" }
        let timestamp = Double(event?.timestamp ?? "")

        XCTAssertEqual(event?.url, launchURL)
        XCTAssertNotNil(timestamp)
        XCTAssertGreaterThanOrEqual(timestamp ?? 0, before)
        XCTAssertLessThanOrEqual(timestamp ?? .infinity, after)
    }

    // MARK: - Background task

    func testEnqueue_holdsABackgroundTaskUntilTheQueueDrains() async {
        recordingAPI.delays["slow"] = 300_000_000
        let ended = expectation(description: "background task ended")
        fakeBackgroundTaskManager.onEndBackgroundTask = { ended.fulfill() }

        makeService().sendEvent("slow")
        await fulfillment(of: [ended], timeout: 5.0)

        XCTAssertEqual(fakeBackgroundTaskManager.beginCount, 1)
        XCTAssertEqual(fakeBackgroundTaskManager.endedIdentifiers.count, 1)
        // The task is only released once the event has actually been sent
        XCTAssertEqual(recordingAPI.sentEventNames, ["slow"])
    }

    func testBackgroundTaskExpiration_endsTheTaskOnlyOnce() async {
        recordingAPI.delays["slow"] = 300_000_000
        let began = expectation(description: "background task began")
        fakeBackgroundTaskManager.onBeginBackgroundTask = { began.fulfill() }
        let delivered = expectation(description: "event delivered")
        recordingAPI.onEventSent = { delivered.fulfill() }

        makeService().sendEvent("slow")
        await fulfillment(of: [began], timeout: 5.0)

        // Simulates the system expiring the task; it must be ended synchronously inside the handler.
        fakeBackgroundTaskManager.expirationHandler?()
        XCTAssertEqual(fakeBackgroundTaskManager.endedIdentifiers.count, 1)

        await fulfillment(of: [delivered], timeout: 5.0)
        // Give the queue's final background task reconciliation time to run
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(fakeBackgroundTaskManager.endedIdentifiers.count, 1)
    }
}

// MARK: - Test Doubles

/// Records the events it is asked to send, with optional per-event delays and failures.
final class RecordingTrackingEventsAPI: AnalyticsEventTracking {

    var delays: [String: UInt64] = [:]
    var failingEventNames: Set<String> = []
    var onEventSent: (() -> Void)?

    private let lock = NSLock()
    private var storedSentEvents: [AnalyticsEventData] = []

    var sentEvents: [AnalyticsEventData] {
        lock.lock()
        defer { lock.unlock() }
        return storedSentEvents
    }

    var sentEventNames: [String] {
        sentEvents.map(\.eventName)
    }

    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        if let delay = delays[analyticsEventData.eventName] {
            try await Task.sleep(nanoseconds: delay)
        }
        if failingEventNames.contains(analyticsEventData.eventName) {
            throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed failure.")
        }

        lock.lock()
        storedSentEvents.append(analyticsEventData)
        lock.unlock()

        onEventSent?()
        return HTTPResponse(status: 200, body: nil)
    }
}

/// Stands in for `UIApplication` so tests do not request real background task assertions from the system.
final class FakeBackgroundTaskManager: BackgroundTaskManaging {

    var onBeginBackgroundTask: (() -> Void)?
    var onEndBackgroundTask: (() -> Void)?

    private let lock = NSLock()
    private var nextIdentifier = 1
    private var storedBeginCount = 0
    private var storedEndedIdentifiers: [UIBackgroundTaskIdentifier] = []
    private var storedExpirationHandler: (() -> Void)?

    var beginCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return storedBeginCount
    }

    var endedIdentifiers: [UIBackgroundTaskIdentifier] {
        lock.lock()
        defer { lock.unlock() }
        return storedEndedIdentifiers
    }

    var expirationHandler: (() -> Void)? {
        lock.lock()
        defer { lock.unlock() }
        return storedExpirationHandler
    }

    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        lock.lock()
        storedBeginCount += 1
        let identifier = UIBackgroundTaskIdentifier(rawValue: nextIdentifier)
        nextIdentifier += 1
        storedExpirationHandler = handler
        lock.unlock()

        onBeginBackgroundTask?()
        return identifier
    }

    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        lock.lock()
        storedEndedIdentifiers.append(identifier)
        lock.unlock()

        onEndBackgroundTask?()
    }
}
