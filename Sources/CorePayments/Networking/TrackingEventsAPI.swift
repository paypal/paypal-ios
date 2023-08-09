import Foundation

/// This class coordinates networking logic for communicating with the v1/tracking/events API.
///
/// Details on this PayPal API can be found in PPaaS under Infrastructure > Experimentation > Tracking Events > v1.
class TrackingEventsAPI {
    
    // MARK: - Internal Functions
        
    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        // api.sandbox.paypal.com does not currently send FPTI events to BigQuery/Looker
        let apiClient = APIClient(coreConfig: CoreConfig(clientID: analyticsEventData.clientID, environment: .live))
        
        // TODO: - Move JSON encoding into custom class, similar to HTTPResponseParser
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(analyticsEventData)
        
        let restRequest = RESTRequest(
            path: "v1/tracking/events",
            method: .post,
            headers: [.contentType: "application/json"],
            queryParameters: nil,
            body: body
        )
        
        return try await apiClient.fetch(request: restRequest)
    }
}
