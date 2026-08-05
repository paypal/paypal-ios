import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Tracks user-perceived ("system") latency for a single checkout or vault flow and emits the
/// `paypal-payments:system-latency` analytics event at most once per flow.
final class SystemLatencyTracker {

    enum Flow: String {

        case checkout
        case vault
    }

    enum PresentationType: String {

        case appSwitch = "app-switch"
        case browser
        case error
    }

    // MARK: - Private Properties

    private let eventName = "paypal-payments:system-latency"

    private var startTime: Int64?

    private var flow: Flow?

    // MARK: - Internal Methods

    func begin(flow: Flow) {
        startTime = Int64(Date().timeIntervalSince1970 * 1000)
        self.flow = flow
    }

    func reset() {
        startTime = nil
        flow = nil
    }

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
