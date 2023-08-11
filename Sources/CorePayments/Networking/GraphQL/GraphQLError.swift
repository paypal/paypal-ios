public struct GraphQLError: Codable, Error {

    let message: String
    let extensions: [Extension]?

    init(message: String, extensions: [Extension]? = nil) {
        self.message = message
        self.extensions = extensions
    }
}

struct Extension: Codable {

    let correlationId: String
}
