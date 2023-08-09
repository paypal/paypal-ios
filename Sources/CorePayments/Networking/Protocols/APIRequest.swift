import Foundation

// TODO: - Remove this protocol once tests are updated 🎉
public protocol APIRequest {
    associatedtype ResponseType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data? { get }
}

public extension APIRequest {

    var queryParameters: [String: String] { [:] }

    var body: Data? { nil }
}
