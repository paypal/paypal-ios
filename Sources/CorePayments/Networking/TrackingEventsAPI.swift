import Foundation

class TrackingEventsAPI {
        
    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        let apiClient = APIClient(coreConfig: CoreConfig(clientID: analyticsEventData.clientID, environment: .live))
        
        // encode the body -- todo move
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(analyticsEventData) // handle with special
        
        let restRequest = RESTRequest(
            path: "v1/tracking/events",
            method: .post,
            headers: [.contentType: "application/json"],
            queryParameters: nil,
            body: body
        )
        
        return try await apiClient.fetch(request: restRequest)
        // skip HTTP parsing!
    }
}
