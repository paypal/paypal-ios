import Foundation

/// `HTTP` interfaces directly with `URLSession` to execute network requests.
class HTTP {
    
    let coreConfig: CoreConfig
    private var urlSession: URLSessionProtocol

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        coreConfig: CoreConfig
    ) {
        self.urlSession = urlSession
        self.coreConfig = coreConfig
    }
    
    func performRequest(_ request: any APIRequest) async throws -> HTTPResponse {
        guard let urlRequest = request.toURLRequest(environment: coreConfig.environment) else {
            throw APIClientError.invalidURLRequestError
        }
        
        let (data, response) = try await urlSession.performRequest(with: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }
        
        return HTTPResponse(status: response.statusCode, body: data)
    }
    
    func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: httpRequest.url)
        urlRequest.httpMethod = httpRequest.method.rawValue
        urlRequest.httpBody = httpRequest.body
        
        httpRequest.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        
        let (data, response) = try await urlSession.performRequest(with: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }
        
        return HTTPResponse(status: response.statusCode, body: data)
    }
}

struct HTTPRequest {
    
    let url: URL
    let method: HTTPMethod
    let body: Data?
    let headers: [HTTPHeader: String]
}
