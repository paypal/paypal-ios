import Foundation

/// Values needed to initiate a GraphQL network request
@_documentation(visibility: private)
public struct GraphQLRequest {
    
    let query: String
    let variables: Encodable
    
    /// This is non-standard in the GraphQL language, but sometimes required by PayPal's GraphQL API.
    /// Some requests are sent to `https://www.api.paypal.com/graphql?<queryNameForURL>`
    let queryNameForURL: String?
    
    public init(query: String, variables: Encodable, queryNameForURL: String? = nil) {
        self.query = query
        self.variables = variables
        self.queryNameForURL = queryNameForURL
    }
}
