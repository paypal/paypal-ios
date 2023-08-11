import Foundation

/// Used to parse error message details out of GraphQL HTTP response body
struct GraphQLErrorResponse: Decodable {
    
    let error: String
    let correlationId: String?
}
