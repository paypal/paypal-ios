import Foundation

/// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// `APIClient` is the entry point for each payment method feature to perform API requests. It also offers convenience methods for API requests used across multiple payment methods / modules.
public class APIClient {
        
    // MARK: - Internal Properties
    
    private var http: HTTP
    private let coreConfig: CoreConfig
    
    // MARK: - Public Initializer

    public init(coreConfig: CoreConfig) {
        self.http = HTTP(coreConfig: coreConfig)
        self.coreConfig = coreConfig
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(http: HTTP) {
        self.http = http
        self.coreConfig = http.coreConfig
    }
    
    // MARK: - Public Methods
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func fetch<T: APIRequest>(request: T) async throws -> (T.ResponseType) {
        let url = try constructURL(path: request.path, queryParameters: request.queryParameters)
        
        let httpRequest = HTTPRequest(
            url: url,
            method: request.method,
            body: request.body,
            headers: request.headers
        )
        
        let httpResponse = try await http.performRequest(httpRequest)
        return try HTTPResponseParser().parse(httpResponse, as: T.ResponseType.self)
    }
    
    public func fetch(request: RESTRequest) async throws -> HTTPResponse {
        let url = try constructURL(path: request.path, queryParameters: request.queryParameters ?? [:]) // cleaner way
        
        let httpRequest = HTTPRequest(
            url: url,
            method: request.method,
            body: request.body,
            headers: request.headers
        )
        
        return try await http.performRequest(httpRequest)
    }
    
    private func constructURL(path: String, queryParameters: [String: String]) throws -> URL {
        let urlString = coreConfig.environment.baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false)
        
        queryParameters.forEach {
            urlComponents?.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let url = urlComponents?.url else {
            throw CorePaymentsError.clientIDNotFoundError // fix
        }
        
        return url
    }
}
