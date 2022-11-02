import Foundation

struct AnalyticsEventRequest: APIRequest {
    
    init(payload: AnalyticsPayload) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        body = try encoder.encode(payload)
    }
    
    // MARK: - APIRequest
    
    typealias ResponseType = EmptyResponse
    
    var path = "v1/tracking/events"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] = [.contentType: "application/json"]
    var body: Data?
    
    // api.sandbox.paypal.com does not currently send FPTI events to BigQuery/Looker
    func toURLRequest(environment: Environment) -> URLRequest? {
        composeURLRequest(environment: .production)
    }
}

public struct EmptyResponse: Decodable { }
