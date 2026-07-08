import Foundation
@testable import CorePayments

class MockTrackingEventsAPI: TrackingEventsAPI {

    var stubHTTPResponse: HTTPResponse?
    var stubError: Error?

    var capturedAnalyticsEventData: AnalyticsEventData?
    var capturedAnalyticsEvents: [AnalyticsEventData] = []

    override func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        capturedAnalyticsEventData = analyticsEventData
        capturedAnalyticsEvents.append(analyticsEventData)

        if let stubError {
            throw stubError
        }

        if let stubHTTPResponse {
            return stubHTTPResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
