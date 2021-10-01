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

    // Default implementation vends response from helper function
    func toURLRequest(environment: Environment) -> URLRequest? {
        composeURLRequest(environment: environment)
    }

    func composeURLRequest(environment: Environment) -> URLRequest? {
        let completeUrl = environment.baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: completeUrl, resolvingAgainstBaseURL: false)

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
