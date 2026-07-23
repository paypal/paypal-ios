import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Tracks user-perceived ("system") latency for a single checkout or vault flow and emits the
/// `paypal-web-payments:system-latency` analytics event at most once per flow.
///
/// Usage: call `begin(flow:)` when `start()`/`vault()` is invoked, then `send(presentationType:...)`
/// once the checkout experience launches (or fails to launch). The recorded start time is consumed on
/// the first `send(...)`, so later terminal points in the same flow won't refire the event. Use
/// `reset()` to discard an in-flight measurement without emitting.
final class SystemLatencyTracker {

    /// Which flow the measurement belongs to.
    enum Flow: String {

        case checkout
        case vault
    }

    /// How the checkout experience was presented when the measurement ended.
    enum PresentationType: String {

        case appSwitch = "app-switch"
        case browser
        case error
    }

    // MARK: - Private Properties

    private let eventName = "paypal-web-payments:system-latency"

    private var startTime: Int64?

    private var flow: Flow?

    // MARK: - Internal Methods

    /// Begins a new measurement, capturing the current time as `start_time`.
    func begin(flow: Flow) {
        startTime = Int64(Date().timeIntervalSince1970 * 1000)
        self.flow = flow
    }

    /// Discards any in-flight measurement without emitting an event.
    func reset() {
        startTime = nil
        flow = nil
    }

    /// Emits the `system-latency` event at most once per `begin(flow:)`, capturing `end_time` now and
    /// then consuming the measurement so subsequent calls in the same flow are no-ops.
    /// - Parameters:
    ///   - presentationType: How the experience was presented — `.appSwitch`, `.browser`, or `.error`.
    ///   - analyticsService: The service used to dispatch the event.
    ///   - checkoutAnalyticsData: Additional analytics context forwarded with the event.
    func send(
        presentationType: PresentationType,
        using analyticsService: AnalyticsService?,
        checkoutAnalyticsData: PayPalCheckoutAnalyticsData?
    ) {
        guard let startTime else { return }
        
        analyticsService?.sendEvent(
            eventName,
            startTime: startTime,
            endTime: Int64(Date().timeIntervalSince1970 * 1000),
            presentationType: presentationType.rawValue,
            flow: flow?.rawValue,
            checkoutAnalyticsData: checkoutAnalyticsData,
            withBackgroundProtection: presentationType == .appSwitch
        )
        self.startTime = nil
    }
}
