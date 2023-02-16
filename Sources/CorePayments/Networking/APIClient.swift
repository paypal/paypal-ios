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
        return try await http.performRequest(request)
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Retrieves the merchant's clientID either from the local cache, or via an HTTP request if not cached.
    /// - Returns: Merchant clientID.
    public func fetchCachedOrRemoteClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(request, withCaching: true)
        return response.clientID
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendAnalyticsEvent(_ name: String) {
        Task(priority: .background) {
            do {
                let clientID = try await fetchCachedOrRemoteClientID()
                let analyticsService = AnalyticsService.sharedInstance(http: http)
                await analyticsService.sendEvent(name: name, clientID: clientID)
            } catch {
                NSLog("[PayPal SDK] Failed to send analytics due to missing clientID: %@", error.localizedDescription.debugDescription)
            }
        }
    }
}
