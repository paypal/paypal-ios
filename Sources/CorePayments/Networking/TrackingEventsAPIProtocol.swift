import Foundation

/// Protocol defining the interface for sending FPTI analytics events.
protocol TrackingEventsAPIProtocol {

    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse
}
