public struct GraphQLError: Codable, Error {

    let message: String
    let extensions: [Extension]?
}

struct Extension: Codable {

    let correlationId: String
}
