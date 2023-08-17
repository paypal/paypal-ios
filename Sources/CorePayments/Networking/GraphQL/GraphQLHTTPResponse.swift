/// :nodoc: Used to decode the HTTP reponse body of GraphQL requests
public struct GraphQLHTTPResponse<T: Codable>: Codable {

    public let data: T?
}
