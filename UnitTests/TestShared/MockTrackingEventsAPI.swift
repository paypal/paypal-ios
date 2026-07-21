import Foundation
@testable import CorePayments

class MockTrackingEventsAPI: TrackingEventsAPI {

    var stubHTTPResponse: HTTPResponse?
    var stubError: Error?
    var sendEventDelay: UInt64 = 0
    var onSendEvent: (() -> Void)?

    var capturedAnalyticsEventData: AnalyticsEventData?
    var capturedAnalyticsEvents: [AnalyticsEventData] = []

    override func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        if sendEventDelay > 0 {
            try await Task.sleep(nanoseconds: sendEventDelay)
        }

        capturedAnalyticsEventData = analyticsEventData
        capturedAnalyticsEvents.append(analyticsEventData)

        onSendEvent?()
        if let stubError {
            throw stubError
        }

        if let stubHTTPResponse {
            return stubHTTPResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
