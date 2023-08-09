import Foundation

struct AnalyticsEventRequest: APIRequest {
    
    init(eventData: AnalyticsEventData) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        body = try encoder.encode(eventData)
    }
    
    // MARK: - APIRequest conformance
    
    typealias ResponseType = EmptyResponse
    
    var path = "v1/tracking/events"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] = [.contentType: "application/json"]
    var body: Data?
    
    // api.sandbox.paypal.com does not currently send FPTI events to BigQuery/Looker
}

struct EmptyResponse: Decodable { }
