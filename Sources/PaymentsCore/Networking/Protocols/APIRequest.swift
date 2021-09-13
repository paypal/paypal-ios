import Foundation

public protocol APIRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data { get }
    var urlRequest: URLRequest? { get }
}
