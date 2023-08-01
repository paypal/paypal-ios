import Foundation

public protocol GraphQLQuery {
    var query: String { get }
    var variables: Variables? { get }
    func requestBody() throws -> Data
}
