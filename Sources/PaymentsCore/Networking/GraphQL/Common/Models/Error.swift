
public struct GraphQLError: Codable {
    let message: String
    let extensions: [Extension]?
}
