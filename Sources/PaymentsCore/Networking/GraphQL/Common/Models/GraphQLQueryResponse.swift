
struct GraphQLQueryResponse<T: Codable>: Codable {
    let data: T?
}
