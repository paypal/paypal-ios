import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
@_documentation(visibility: private)
public struct AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let trackingEventsAPI: TrackingEventsAPI
    private let orderID: String?
    private let setupToken: String?
    // MARK: - Initializer
    
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.orderID = orderID
        self.setupToken = nil
    }

    public init(coreConfig: CoreConfig, setupToken: String) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.setupToken = setupToken
        self.orderID = nil
    }

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.orderID = nil
        self.setupToken = nil
    }

    // MARK: - Internal Initializer

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = orderID
        self.setupToken = nil
    }

    /// Exposed for testing
    init(coreConfig: CoreConfig, setupToken: String, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = nil
        self.setupToken = setupToken
    }

    /// Exposed for testing
    init(coreConfig: CoreConfig, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = nil
        self.setupToken = nil
    }
    
    // MARK: - Public Methods
        
    /// This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    /// - Parameter correlationID: correlation ID associated with the request
    /// - Parameter buttonType: The type of button
    public func sendEvent(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
    ) {
        Task(priority: .background) {
            await performEventRequest(
                name,
                correlationID: correlationID,
                buttonType: buttonType,
                startTime: startTime,
                endTime: endTime,
                endpoint: endpoint,
                presentationType: presentationType,
                flow: flow
            )
        }
    }

    /// Sends an analytics event and waits for the request to complete.
    public func sendEventAndAwaitDelivery(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
    ) async {
        await performEventRequest(
            name,
            correlationID: correlationID,
            buttonType: buttonType,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint,
            presentationType: presentationType,
            flow: flow
        )
    }

    // MARK: - Internal Methods
    
    /// Exposed to be able to execute this function synchronously in unit tests
    /// - Parameters:
    ///   - name: Event name string used to identify this unique event in FPTI
    ///   - correlationID: correlation ID associated with the request
    ///   - buttonType: The type of button
    func performEventRequest(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
    ) async {
        do {
            let clientID = coreConfig.clientID

            let eventData = AnalyticsEventData(
                environment: coreConfig.environment.toString,
                eventName: name,
                clientID: clientID,
                orderID: orderID,
                correlationID: correlationID,
                setupToken: setupToken,
                buttonType: buttonType,
                startTime: startTime,
                endTime: endTime,
                endpoint: endpoint,
                presentationType: presentationType,
                flow: flow
            )

            let (_) = try await trackingEventsAPI.sendEvent(with: eventData)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
