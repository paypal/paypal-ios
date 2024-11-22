import Foundation

/// `HTTP` constructs `URLRequest`s and interfaces directly with `URLSession` to execute network requests.
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
    
    func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: httpRequest.url)
        urlRequest.httpMethod = httpRequest.method.rawValue
        urlRequest.httpBody = httpRequest.body
        
        httpRequest.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.performRequest(with: urlRequest)
        } catch _ as URLError {
            throw NetworkingError.urlSessionError
        } catch {
            throw NetworkingError.unknownError
        }

        guard let response = response as? HTTPURLResponse else {
            throw NetworkingError.invalidURLResponseError
        }
        
        return HTTPResponse(status: response.statusCode, body: data)
    }
}
