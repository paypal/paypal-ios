import Foundation

/// The GraphQL query and variable details encoded to be sent in the POST body of a HTTP request
struct GraphQLHTTPPostBody: Encodable {
    
    let query: String
    let variables: Data
}
