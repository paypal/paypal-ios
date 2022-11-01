import Foundation

struct AnalyticsEventRequest: APIRequest {
    
    // MARK: - APIRequest
    
    typealias ResponseType = EmptyResponse
    
    var path = "v1/tracking/events"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] = [.contentType: "application/json"]
    var body: Data?
    
    init(payload: AnalyticsPayload) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        body = try encoder.encode(payload)
    }
}

public struct EmptyResponse: Decodable {
    
}
