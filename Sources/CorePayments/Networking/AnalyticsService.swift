import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
@_documentation(visibility: private)
public class AnalyticsService {

    // MARK: - Internal Properties

    private let coreConfig: CoreConfig
    private let trackingEventsAPI: TrackingEventsAPI
    public var orderID: String?
    public var setupToken: String?

    // MARK: - Initializer

    /// Primary initializer — clients hold a single `let` reference and
    /// set `orderID` / `setupToken` per-flow.
    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.orderID = nil
        self.setupToken = nil
    }

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

    // MARK: - Internal Initializer

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = orderID
        self.setupToken = nil
    }

    // MARK: - Public Methods

    /// This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Sends an analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter event: A type-safe analytics event defined by a PayPal SDK module.
    /// - Parameter correlationID: correlation ID associated with the request
    /// - Parameter buttonType: The type of button
    public func track(_ event: AnalyticsEventName, correlationID: String? = nil, buttonType: String? = nil) {
        track(event.eventName, correlationID: correlationID, buttonType: buttonType)
    }

    // MARK: - Internal Methods

    /// Sends an analytics event by raw FPTI event name.
    ///
    /// Prefer the `AnalyticsEventName` overload. This string-based entry point is
    /// retained for cross-module internal use and unit tests that need to inspect
    /// the emitted event name directly.
    func track(_ name: String, correlationID: String? = nil, buttonType: String? = nil) {
        Task(priority: .background) {
            await performTrackRequest(name, correlationID: correlationID, buttonType: buttonType)
        }
    }

    /// Exposed to be able to execute this function synchronously in unit tests
    /// - Parameters:
    ///   - name: Event name string used to identify this unique event in FPTI
    ///   - correlationID: correlation ID associated with the request
    ///   - buttonType: The type of button
    func performTrackRequest(_ name: String, correlationID: String? = nil, buttonType: String? = nil) async {
        do {
            let clientID = coreConfig.clientID

            let eventData = AnalyticsEventData(
                environment: coreConfig.environment.toString,
                eventName: name,
                clientID: clientID,
                orderID: orderID,
                correlationID: correlationID,
                setupToken: setupToken,
                buttonType: buttonType
            )

            let (_) = try await trackingEventsAPI.sendEvent(with: eventData)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
