/// :nodoc: Used to decode the HTTP reponse body of GraphQL requests
public struct GraphQLHTTPResponse<T: Decodable>: Decodable {

    public let data: T?
}
