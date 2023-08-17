//// :nodoc: Struct to handle nested response from GraphQL response
public struct GraphQLQueryResponse<T: Codable>: Codable {

    public let data: T?
}
