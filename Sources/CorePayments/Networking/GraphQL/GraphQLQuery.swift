import Foundation

//// :nodoc: Protocol for requests made to GraphQL endpoints
public protocol GraphQLQuery {
    associatedtype VariablesType: Codable
    var query: String { get }
    var variables: VariablesType? { get }
    func requestBody() throws -> Data
}
