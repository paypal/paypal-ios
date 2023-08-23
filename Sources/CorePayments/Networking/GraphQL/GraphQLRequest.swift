import Foundation

/// :nodoc: Values needed to initiate a GraphQL network request
public struct GraphQLRequest {
    
    let query: String
    let variables: [String: Any]
    
    /// This is non-standard in the GraphQL language, but sometimes required by PayPal's GraphQL API.
    /// Some requests are sent to `https://www.api.paypal.com/graphql?<queryNameForURL>`
    let queryNameForURL: String?
    
    public init(query: String, variables: [String: Any], queryNameForURL: String?) {
        self.query = query
        self.variables = variables
        self.queryNameForURL = queryNameForURL
    }
}
