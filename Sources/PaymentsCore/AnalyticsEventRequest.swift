import Foundation

struct AnalyticsEventRequest: APIRequest {
    
    // MARK: - APIRequest
    
    typealias ResponseType = EmptyResponse
    
    var path = "v1/tracking/events"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] = [.contentType: "application/json"]
    var body: Data
    
    init(params: AnalyticsEventParams) throws {
        let encoder = JSONEncoder()
        body = try encoder.encode(params)
    }
    
}

public struct EmptyResponse: Decodable {
    
}
