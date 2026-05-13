import Foundation

/// Protocol defining the interface for sending FPTI analytics events.
protocol AnalyticsEventTracking {

    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse
}
