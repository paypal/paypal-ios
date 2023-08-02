import Foundation

public protocol GraphQLQuery {
    associatedtype VariablesType: Codable
    var query: String { get }
    var variables: VariablesType? { get }
    func requestBody() throws -> Data
}
