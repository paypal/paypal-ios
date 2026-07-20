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

    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
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
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
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
                startTime: startTime,
                endTime: endTime,
                endpoint: endpoint,
                presentationType: presentationType,
                flow: flow
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

    private func sendEventWithBackgroundProtection(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
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
                    startTime: startTime,
                    endTime: endTime,
                    endpoint: endpoint,
                    presentationType: presentationType,
                    flow: flow
                )
            }

            await eventTask?.value
            endBackgroundTaskIfNeeded()
        }
    }

    // MARK: - Internal Methods

    func performEventRequest(
        _ name: String,
        correlationID: String? = nil,
        buttonType: String? = nil,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
    ) async {
        guard !Task.isCancelled else { return }
        do {
            let eventData = AnalyticsEventData(
                environment: coreConfig.environment.toString,
                eventName: name,
                clientID: coreConfig.clientID,
                orderID: orderID,
                correlationID: correlationID,
                setupToken: setupToken,
                buttonType: buttonType,
                appSwitchURL: appSwitchURL,
                errorDescription: errorDescription,
                isCachedSession: isCachedSession,
                isVaultRequest: isVaultRequest,
                shopperSessionId: shopperSessionId,
                startTime: startTime,
                endTime: endTime,
                endpoint: endpoint,
                presentationType: presentationType,
                flow: flow
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
