
import Foundation

internal protocol GraphQLQuery {
    var query: String {get}
    var variables: [String: Any] {get}
    func requestBody() throws -> Data
}
