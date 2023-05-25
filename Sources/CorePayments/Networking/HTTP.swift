import Foundation

/// `HTTP` interfaces directly with `URLSession` to execute network requests.
class HTTP {
    
    let coreConfig: CoreConfig
    private var urlSession: URLSessionProtocol
    private var urlCache: URLCacheable
    private let decoder = APIClientDecoder()

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        urlCache: URLCacheable = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 0),
        coreConfig: CoreConfig
    ) {
        self.urlSession = urlSession
        self.urlCache = urlCache
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
}
