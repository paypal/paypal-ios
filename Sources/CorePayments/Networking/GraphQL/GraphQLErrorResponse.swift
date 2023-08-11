import Foundation

struct GraphQLErrorResponse: Decodable {
    
    let error: String
    let correlationId: String?
}
