import Foundation

struct AnalyticsEventRequest: APIRequest {
    
    // MARK: - APIRequest
    
    typealias ResponseType = EmptyResponse
    
    var path = "v1/tracking/events"
    
    var method: HTTPMethod = .post
    
    var headers: [HTTPHeader: String] = [.contentType: "application/json"]
    
    init(name: String) {
        
    }
    
}

public struct EmptyResponse: Decodable {
    
}
