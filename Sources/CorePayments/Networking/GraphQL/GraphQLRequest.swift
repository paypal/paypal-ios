import Foundation

/// :nodoc:
public struct GraphQLRequest {
    
    let queryNameForURL: String?
    let query: String
    let variables: Data // Dictionary
}
