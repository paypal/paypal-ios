import Foundation

public protocol APIRequest {
    associatedtype ResponseType: Codable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data? { get }

    func toURLRequest(environment: Environment) -> URLRequest?
}

public extension APIRequest {
    var queryParameters: [String: String] { [:] }

    func toURLRequest(environment: Environment) -> URLRequest? {
        var urlComponents = URLComponents(url: environment.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)

        queryParameters.forEach {
            urlComponents?.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key.rawValue)
        }

        return request
    }
}

