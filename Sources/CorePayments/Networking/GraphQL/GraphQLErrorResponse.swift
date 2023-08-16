import Foundation

/// Used to parse error message details out of GraphQL HTTP response body
struct GraphQLErrorResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case error = "error"
        case correlationID = "correlation_id"
    }
    
    let error: String
    let correlationID: String?
}
