import Foundation

/// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// `APIClient` is the entry point for each payment method feature to perform API requests. It also offers convenience methods for API requests used across multiple payment methods / modules.
public class APIClient {
        
    // MARK: - Internal Properties
    
    private let analyticsService: AnalyticsService
    private var http: HTTP
    private let coreConfig: CoreConfig
    
    // MARK: - Public Initializer

    public init(coreConfig: CoreConfig) {
        self.http = HTTP(coreConfig: coreConfig)
        self.coreConfig = coreConfig
        self.analyticsService = AnalyticsService(http: http)
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(urlSession: URLSessionProtocol, coreConfig: CoreConfig) {
        self.http = HTTP(urlSession: urlSession, coreConfig: coreConfig)
        self.coreConfig = coreConfig
        self.analyticsService = AnalyticsService(http: http)
    }
    
    // MARK: - Public Methods
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func fetch<T: APIRequest>(endpoint: T) async throws -> (T.ResponseType) {
        return try await http.performRequest(endpoint: endpoint)
    }

    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func getClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(endpoint: request)
        return response.clientID
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendAnalyticsEvent(_ name: String) async {
        await analyticsService.sendEvent(name)
    }
}
