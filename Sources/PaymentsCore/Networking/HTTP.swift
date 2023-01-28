import Foundation

/// `HTTP` interfaces directly with `URLSession` to execute network requests.
class HTTP {
    
    let coreConfig: CoreConfig
    private var urlSession: URLSessionProtocol
    private var urlCache: URLCacheTestable
    private let decoder = APIClientDecoder()

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        urlCache: URLCacheTestable = URLCache.shared,
        coreConfig: CoreConfig
    ) {
        self.urlSession = urlSession
        self.urlCache = urlCache
        self.coreConfig = coreConfig
    }
    
    func performRequest<T: APIRequest>(_ request: T, withCaching: Bool = false) async throws -> (T.ResponseType) {
        guard let urlRequest = request.toURLRequest(environment: coreConfig.environment) else {
            throw APIClientError.invalidURLRequestError
        }
        
        if withCaching, let response = urlCache.cachedResponse(for: urlRequest) {
            let decodedData = try decoder.decode(T.self, from: response.data)
            return (decodedData)
        }
        
        let (data, response) = try await urlSession.performRequest(with: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }
        
        if withCaching {
            let cachedURLResponse = CachedURLResponse(response: response, data: data)
            urlCache.storeCachedResponse(cachedURLResponse, for: urlRequest)
        }
        
        switch response.statusCode {
        case 200..<300:
            let decodedData = try decoder.decode(T.self, from: data)
            return (decodedData)
        default:
            let errorData = try decoder.decode(from: data)
            throw APIClientError.serverResponseError(errorData.readableDescription)
        }
    }
}
