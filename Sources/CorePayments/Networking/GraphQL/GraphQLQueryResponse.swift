public struct GraphQLQueryResponse<T: Codable>: Codable {

    public let data: T?
}
