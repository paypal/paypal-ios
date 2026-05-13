import Foundation
@testable import CorePayments

class MockAnalyticsEventTrackingAPI: AnalyticsEventTracking {

    var stubHTTPResponse: HTTPResponse?
    var stubError: Error?

    var capturedAnalyticsEventData: AnalyticsEventData?
    private(set) var sendEventCallCount = 0

    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        sendEventCallCount += 1
        capturedAnalyticsEventData = analyticsEventData

        if let stubError {
            throw stubError
        }

        if let stubHTTPResponse {
            return stubHTTPResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
