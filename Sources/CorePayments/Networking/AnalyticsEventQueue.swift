import UIKit

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

    /// Sends the event, cancelling the request if it takes longer than the timeout.
    ///
    /// The timeout runs as its own task that is cancelled (but deliberately not awaited) once the send finishes,
    /// so a finished send never waits on the timeout's sleep to wind down before the next event can start.
    private func sendWithTimeout(_ queuedEvent: QueuedEvent) async {
        let timeout = requestTimeoutNanoseconds
        let sendTask = Task {
            await AnalyticsEventQueue.send(queuedEvent.eventData, using: queuedEvent.trackingEventsAPI)
        }
        let timeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: timeout)
            } catch {
                return
            }
            sendTask.cancel()
        }

        await sendTask.value
        timeoutTask.cancel()
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
