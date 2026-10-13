import UIKit

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
@_documentation(visibility: private)
public struct AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let trackingEventsAPI: AnalyticsEventTracking
    private let eventQueue: AnalyticsEventQueue
    private let orderID: String?
    private let setupToken: String?
    // MARK: - Initializer
    
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.eventQueue = .shared
        self.orderID = orderID
        self.setupToken = nil
    }

    public init(coreConfig: CoreConfig, setupToken: String) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.eventQueue = .shared
        self.setupToken = setupToken
        /// Android logs setup token as "order_id" this is to ensure parity between platforms 
        self.orderID = setupToken
    }

    // MARK: - Internal Initializer

    /// This initializer is exposed for internal PayPal use only. Do not use. It is not covered by Semantic
    /// Versioning and may change or be removed at any time.
    /// For internal use by `PayPalClient`, which lives in a separate module (`PayPalPayments`)
    /// and therefore needs `public` (rather than `internal`) visibility to construct an `AnalyticsService`
    /// with no `orderID`/`setupToken` yet known.
    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.eventQueue = .shared
        self.orderID = nil
        self.setupToken = nil
    }

    /// Exposed for testing
    init(
        coreConfig: CoreConfig,
        orderID: String,
        trackingEventsAPI: AnalyticsEventTracking,
        eventQueue: AnalyticsEventQueue = .shared
    ) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.eventQueue = eventQueue
        self.orderID = orderID
        self.setupToken = nil
    }
    
    // MARK: - Public Methods
        
    /// This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a shared, ordered send queue.
    ///
    /// The event payload (including the event time and a copy of `checkoutAnalyticsData`) is built synchronously
    /// when this method is called, so it reflects the state at the moment the event occurred even if the network
    /// request is delayed. Events are sent one at a time in the order they were fired, and the app is given
    /// additional runtime to finish sending them if it enters the background (e.g. during an app switch).
    /// Delivery is best-effort and not guaranteed.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    /// - Parameter correlationID: correlation ID associated with the request
    /// - Parameter buttonType: The type of button
    /// - Parameter errorDescription: A human-readable description of the error, when the event represents a failure
    /// - Parameter startTime: Start time of the measured API call, in epoch milliseconds (for `api-request-latency`)
    /// - Parameter endTime: End time of the measured API call, in epoch milliseconds (for `api-request-latency`)
    /// - Parameter endpoint: Sanitized API path of the measured API call (for `api-request-latency`)
    /// - Parameter presentationType: How the checkout experience was presented (for `system-latency`)
    /// - Parameter flow: Which flow the measurement is for, `checkout` or `vault` (for `system-latency`)
    public func sendEvent(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        errorDescription: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil,
        checkoutAnalyticsData: PayPalCheckoutAnalyticsData? = nil
    ) {
        let eventData = makeEventData(
            name,
            correlationID: correlationID,
            buttonType: buttonType,
            errorDescription: errorDescription,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint,
            presentationType: presentationType,
            flow: flow,
            checkoutAnalyticsData: checkoutAnalyticsData
        )
        eventQueue.enqueue(eventData, using: trackingEventsAPI)
    }

    // MARK: - Internal Methods

    /// Builds the event payload. Exposed for testing.
    ///
    /// Everything that can change over time (event time, order ID, shopper/session state) is captured here.
    /// - Parameters:
    ///   - name: Event name string used to identify this unique event in FPTI
    ///   - correlationID: correlation ID associated with the request
    ///   - buttonType: The type of button
    ///   - errorDescription: A human-readable description of the error, when the event represents a failure
    ///   - startTime: Start time of the operation being measured, in milliseconds since epoch
    ///   - endTime: End time of the operation being measured, in milliseconds since epoch
    ///   - endpoint: Sanitized API path of the operation being measured
    ///   - presentationType: How the checkout experience was presented (for `system-latency`)
    ///   - flow: Which flow the measurement is for, `checkout` or `vault` (for `system-latency`)
    ///   - checkoutAnalyticsData: Session state (URLs, shopper session, vault flag, etc.) at the time of the event
    func makeEventData(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        errorDescription: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil,
        checkoutAnalyticsData: PayPalCheckoutAnalyticsData? = nil
    ) -> AnalyticsEventData {
        AnalyticsEventData(
            environment: coreConfig.environment.toString,
            eventName: name,
            clientID: coreConfig.clientID,
            merchantID: coreConfig.merchantID,
            bnCode: coreConfig.bnCode,
            orderID: orderID,
            correlationID: correlationID,
            setupToken: setupToken,
            buttonType: buttonType,
            errorDescription: errorDescription,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint,
            presentationType: presentationType,
            flow: flow,
            checkoutAnalyticsData: checkoutAnalyticsData
        )
    }

    /// Builds and sends an event immediately (bypassing the queue), awaiting the network request.
    /// Exposed to be able to execute this function synchronously in unit tests.
    func performEventRequest(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        errorDescription: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil,
        checkoutAnalyticsData: PayPalCheckoutAnalyticsData? = nil
    ) async {
        guard !Task.isCancelled else { return }

        let eventData = makeEventData(
            name,
            correlationID: correlationID,
            buttonType: buttonType,
            errorDescription: errorDescription,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint,
            presentationType: presentationType,
            flow: flow,
            checkoutAnalyticsData: checkoutAnalyticsData
        )
        await AnalyticsEventQueue.send(eventData, using: trackingEventsAPI)
    }
}
