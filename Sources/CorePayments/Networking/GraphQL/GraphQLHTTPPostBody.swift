import Foundation

/// The GraphQL query and variable details encoded to be sent in the POST body of a HTTP request
struct GraphQLHTTPPostBody: Encodable {
    
    private let query: String
    private let variables: Encodable
    
    enum CodingKeys: CodingKey {
        case query
        case variables
    }
    
    init(query: String, variables: Encodable) {
        self.query = query
        self.variables = variables
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.query, forKey: .query)
        try container.encode(self.variables, forKey: .variables)
    }
}
