import UIKit

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
        /// Android logs setup token as "order_id" this is to ensure parity between platforms 
        self.orderID = setupToken
    }

    // MARK: - Internal Initializer

    /// This initializer is exposed for internal PayPal use only. Do not use. It is not covered by Semantic
    /// Versioning and may change or be removed at any time.
    /// For internal use by `PayPalWebCheckoutClient`, which lives in a separate module (`PayPalWebPayments`)
    /// and therefore needs `public` (rather than `internal`) visibility to construct an `AnalyticsService`
    /// with no `orderID`/`setupToken` yet known.
    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.orderID = nil
        self.setupToken = nil
    }

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = orderID
        self.setupToken = nil
    }
    
    // MARK: - Public Methods
        
    /// This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    /// - Parameter correlationID: correlation ID associated with the request
    /// - Parameter buttonType: The type of button
    /// - Parameter withBackgroundProtection: When `true`, requests additional runtime if the app enters
    ///   the background before the network request completes. Delivery is best-effort and not guaranteed.
    /// - Parameter appSwitchURL: The URL used to attempt an app switch, when applicable
    /// - Parameter errorDescription: A human-readable description of the error, when the event represents a failure
    /// - Parameter isCachedSession: Whether the Shopper Session used for this event was served from cache
    /// - Parameter isVaultRequest: Whether this event is part of a vault (save payment method) request
    /// - Parameter shopperSessionId: The Shopper Session ID associated with this event
    /// - Parameter startTime: Start time of the operation being measured, in milliseconds since epoch
    public func sendEvent(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        withBackgroundProtection: Bool = false,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int? = nil
    ) {
        if withBackgroundProtection {
            sendEventWithBackgroundProtection(
                name,
                correlationID: correlationID,
                buttonType: buttonType,
                appSwitchURL: appSwitchURL,
                errorDescription: errorDescription,
                isCachedSession: isCachedSession,
                isVaultRequest: isVaultRequest,
                shopperSessionId: shopperSessionId,
                startTime: startTime
            )
            return
        }
        Task(priority: .background) {
            await performEventRequest(
                name,
                correlationID: correlationID,
                buttonType: buttonType,
                appSwitchURL: appSwitchURL,
                errorDescription: errorDescription,
                isCachedSession: isCachedSession,
                isVaultRequest: isVaultRequest,
                shopperSessionId: shopperSessionId,
                startTime: startTime
            )
        }
    }

    private func sendEventWithBackgroundProtection(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int? = nil
    ) {
        Task { @MainActor in
            var bgTaskID: UIBackgroundTaskIdentifier = .invalid
            var eventTask: Task<Void, Never>?

            @MainActor
            func endBackgroundTaskIfNeeded() {
                guard bgTaskID != .invalid else { return }
                UIApplication.shared.endBackgroundTask(bgTaskID)
                bgTaskID = .invalid
            }

            bgTaskID = UIApplication.shared.beginBackgroundTask(withName: "fpti-event") {
                eventTask?.cancel()
                Task { @MainActor in
                    endBackgroundTaskIfNeeded()
                }
            }

            eventTask = Task(priority: .utility) {
                await performEventRequest(
                    name,
                    correlationID: correlationID,
                    buttonType: buttonType,
                    appSwitchURL: appSwitchURL,
                    errorDescription: errorDescription,
                    isCachedSession: isCachedSession,
                    isVaultRequest: isVaultRequest,
                    shopperSessionId: shopperSessionId,
                    startTime: startTime
                )
            }

            await eventTask?.value
            endBackgroundTaskIfNeeded()
        }
    }

    // MARK: - Internal Methods

    /// Exposed to be able to execute this function synchronously in unit tests
    /// - Parameters:
    ///   - name: Event name string used to identify this unique event in FPTI
    ///   - correlationID: correlation ID associated with the request
    ///   - buttonType: The type of button
    ///   - appSwitchURL: The URL used to attempt an app switch, when applicable
    ///   - errorDescription: A human-readable description of the error, when the event represents a failure
    ///   - isCachedSession: Whether the Shopper Session used for this event was served from cache
    ///   - isVaultRequest: Whether this event is part of a vault (save payment method) request
    ///   - shopperSessionId: The Shopper Session ID associated with this event
    ///   - startTime: Start time of the operation being measured, in milliseconds since epoch
    func performEventRequest(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int? = nil
    ) async {
        guard !Task.isCancelled else { return }
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
                appSwitchURL: appSwitchURL,
                errorDescription: errorDescription,
                isCachedSession: isCachedSession,
                isVaultRequest: isVaultRequest,
                shopperSessionId: shopperSessionId,
                startTime: startTime
            )

            let (_) = try await trackingEventsAPI.sendEvent(with: eventData)
        } catch {
            if Task.isCancelled || error is CancellationError {
                return
            }
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
