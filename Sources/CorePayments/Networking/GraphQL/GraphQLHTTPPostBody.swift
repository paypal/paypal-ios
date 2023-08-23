import Foundation

/// The GraphQL query and variable details encoded to be sent in the POST body of a HTTP request
struct GraphQLHTTPPostBody {
    
    let data: Data
    
    init(query: String, variables: [String: Any]) throws {
        let body: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        self.data = try JSONSerialization.data(withJSONObject: body, options: [])
    }
}
