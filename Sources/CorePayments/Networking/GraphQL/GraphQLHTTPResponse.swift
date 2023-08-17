/// :nodoc: Used to decode the HTTP reponse body of GraphQL requests
<<<<<<< HEAD
public struct GraphQLHTTPResponse<T: Decodable>: Decodable {
=======
public struct GraphQLHTTPResponse<T: Codable>: Codable {
>>>>>>> d7209b9 (WIP - Add VaultPPasSAPI.swift)

    public let data: T?
}
