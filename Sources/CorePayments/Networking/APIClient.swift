import Foundation

// TODO: - Rename to `NetworkingClient`. Now that we have `<PPaaS>API.swift` classes, ths responsibility of this class really is to coordinate networking. It transforms REST & GraphQL into HTTP requests.
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
    
    /// :nodoc:
    public func fetch(request: RESTRequest) async throws -> HTTPResponse {
        let url = try constructURL(path: request.path, queryParameters: request.queryParameters ?? [:])
        
        let base64EncodedCredentials = Data(coreConfig.clientID.appending(":").utf8).base64EncodedString()
        
        var headers: [HTTPHeader: String] = [
            .authorization: "Basic \(base64EncodedCredentials)"
        ]
        
        if request.method == .post {
            headers[.contentType] = "application/json"
        }
        
        let httpRequest = HTTPRequest(
            headers: headers,
            method: request.method,
            url: url,
            body: request.body
        )
        
        return try await http.performRequest(httpRequest)
    }
    
    /// :nodoc:
    public func fetch(request: GraphQLRequest) async throws -> HTTPResponse {
        let url = try constructGraphQLURL(queryName: request.queryNameForURL)

        let postBody = GraphQLHTTPPostBody(query: request.query, variables: request.variables)
        let postData = try JSONEncoder().encode(postBody)
                
        let httpRequest = HTTPRequest(
            headers: [.contentType: "application/json"],
            method: .post,
            url: url,
            body: postData
        )
        
        return try await http.performRequest(httpRequest)
    }
    
    // MARK: - Private Methods
    
    private func constructGraphQLURL(queryName: String? = nil) throws -> URL {
        guard let queryName else {
            return coreConfig.environment.graphQLURL
        }
        
        if let url = URL(string: coreConfig.environment.graphQLURL.absoluteString + "?" + queryName) {
            return url
        } else {
            throw CorePaymentsError.urlEncodingFailed
        }
    }
    
    private func constructURL(path: String, queryParameters: [String: String]) throws -> URL {
        let urlString = coreConfig.environment.baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false)
        
        queryParameters.forEach {
            urlComponents?.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let url = urlComponents?.url else {
            throw CorePaymentsError.urlEncodingFailed
        }
        
        return url
    }
}
