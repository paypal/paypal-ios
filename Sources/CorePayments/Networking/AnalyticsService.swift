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

// MARK: - BackgroundTaskManaging

/// Used to mock `UIApplication`'s background task assertion API so that unit tests do not request
/// real task assertions from the system.
protocol BackgroundTaskManaging {

    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: BackgroundTaskManaging {

    /// Adapts `beginBackgroundTask(withName:expirationHandler:)` to `BackgroundTaskManaging`. The adapter exists so the
    /// protocol requirement can use a plain `(() -> Void)?` handler rather than UIKit's `(@MainActor @Sendable () -> Void)?`,
    /// which would otherwise have to be matched exactly by every conforming test double.
    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTask(withName: named, expirationHandler: handler)
    }
}

// MARK: - AnalyticsEventQueue

/// Sends analytics events one at a time, in the order they were enqueued, and keeps the app alive long enough to
/// flush them if it is backgrounded (e.g. during an app switch).
///
/// Previously each event was sent from its own independent `Task(priority: .background)`. Those tasks ran in no
/// particular order, and the OS held them while the app was suspended, so events fired before an app switch were
/// only delivered once the app returned, interleaved with events fired after it.
///
/// This is intentionally not a batching queue: every event is still sent as its own request, to the same endpoint,
/// with the same payload as before. The queue is shared by every `AnalyticsService` instance so ordering holds
/// across clients, and each queued event keeps the `AnalyticsEventTracking` it was created with.
final class AnalyticsEventQueue: @unchecked Sendable {

    // MARK: - Types

    private struct QueuedEvent {

        let eventData: AnalyticsEventData
        let trackingEventsAPI: AnalyticsEventTracking
    }

    // MARK: - Internal Properties

    static let shared = AnalyticsEventQueue()

    // MARK: - Private Properties

    /// Guards `pendingEvents`, `isDraining`, and `backgroundTaskID`. Only held for short, synchronous sections.
    private let lock = NSLock()
    private var pendingEvents: [QueuedEvent] = []
    private var isDraining = false
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    private let backgroundTaskManager: BackgroundTaskManaging?
    private let requestTimeoutNanoseconds: UInt64

    // MARK: - Initializer

    /// - Parameters:
    ///   - backgroundTaskManager: Used to request background execution time. Defaults to `UIApplication.shared`,
    ///     which is resolved lazily on the main actor.
    ///   - requestTimeout: The longest to wait for a single request before moving on to the next event, so one
    ///     stalled request cannot hold up (or keep the app alive for) every event queued behind it.
    init(backgroundTaskManager: BackgroundTaskManaging? = nil, requestTimeout: TimeInterval = 15) {
        self.backgroundTaskManager = backgroundTaskManager
        self.requestTimeoutNanoseconds = UInt64(requestTimeout * 1_000_000_000)
    }

    // MARK: - Internal Methods

    /// Adds an event to the queue. Safe to call from any thread, and returns immediately.
    func enqueue(_ eventData: AnalyticsEventData, using trackingEventsAPI: AnalyticsEventTracking) {
        lock.lock()
        pendingEvents.append(QueuedEvent(eventData: eventData, trackingEventsAPI: trackingEventsAPI))
        let shouldStartDraining = !isDraining
        isDraining = true
        lock.unlock()

        reconcileBackgroundTask()

        guard shouldStartDraining else { return }
        Task(priority: .utility) {
            await drain()
        }
    }

    /// Sends a single event, awaiting the network request. Failures are logged and the event is dropped.
    static func send(_ eventData: AnalyticsEventData, using trackingEventsAPI: AnalyticsEventTracking) async {
        guard !Task.isCancelled else { return }
        do {
            let (_) = try await trackingEventsAPI.sendEvent(with: eventData)
        } catch {
            if Task.isCancelled || error is CancellationError {
                return
            }
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func drain() async {
        while let queuedEvent = dequeueNextOrFinish() {
            await sendWithTimeout(queuedEvent)
        }
        reconcileBackgroundTask()
    }

    /// Returns the next event, or marks the queue as idle (atomically with the emptiness check, so an event
    /// enqueued concurrently either gets picked up by this loop or starts a new one) and returns `nil`.
    private func dequeueNextOrFinish() -> QueuedEvent? {
        lock.lock()
        defer { lock.unlock() }

        guard !pendingEvents.isEmpty else {
            isDraining = false
            return nil
        }
        return pendingEvents.removeFirst()
    }

    private func sendWithTimeout(_ queuedEvent: QueuedEvent) async {
        let timeout = requestTimeoutNanoseconds
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await AnalyticsEventQueue.send(queuedEvent.eventData, using: queuedEvent.trackingEventsAPI)
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: timeout)
            }
            _ = await group.next()
            group.cancelAll()
        }
    }

    // MARK: - Private Methods: Background Task

    private var isBusy: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isDraining
    }

    /// Holds a background task while events are queued or in flight, and releases it once the queue is drained.
    ///
    /// This reads the current queue state rather than reacting to individual events, so it does not matter in
    /// which order these main-actor hops run.
    private func reconcileBackgroundTask() {
        Task { @MainActor in
            let manager: BackgroundTaskManaging = backgroundTaskManager ?? UIApplication.shared
            if isBusy {
                beginBackgroundTaskIfNeeded(using: manager)
            } else {
                endBackgroundTaskIfNeeded(using: manager)
            }
        }
    }

    private func beginBackgroundTaskIfNeeded(using manager: BackgroundTaskManaging) {
        guard currentBackgroundTaskID() == .invalid else { return }

        let identifier = manager.beginBackgroundTask(named: "fpti-events") { [weak self] in
            // Called by the system just before it suspends the app. The task must be ended synchronously here.
            self?.endBackgroundTaskIfNeeded(using: manager)
        }
        setBackgroundTaskID(identifier)
    }

    private func endBackgroundTaskIfNeeded(using manager: BackgroundTaskManaging) {
        let identifier = takeBackgroundTaskID()
        guard identifier != .invalid else { return }
        manager.endBackgroundTask(identifier)
    }

    private func currentBackgroundTaskID() -> UIBackgroundTaskIdentifier {
        lock.lock()
        defer { lock.unlock() }
        return backgroundTaskID
    }

    private func setBackgroundTaskID(_ identifier: UIBackgroundTaskIdentifier) {
        lock.lock()
        defer { lock.unlock() }
        backgroundTaskID = identifier
    }

    /// Returns the current identifier and resets it, so a task is never ended twice (e.g. on expiry and on drain).
    private func takeBackgroundTaskID() -> UIBackgroundTaskIdentifier {
        lock.lock()
        defer { lock.unlock() }
        let identifier = backgroundTaskID
        backgroundTaskID = .invalid
        return identifier
    }
}
