/// Used to decode the HTTP reponse body of GraphQL requests
@_documentation(visibility: private)
public struct GraphQLHTTPResponse<T: Decodable>: Decodable {

    public let data: T?
}
