/// Used to decode the HTTP reponse body of GraphQL requests
struct GraphQLHTTPResponse<T: Codable>: Codable {

    let data: T?
}
