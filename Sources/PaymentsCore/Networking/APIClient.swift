import Foundation

/// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// `APIClient` is the entry point for each payment method feature to perform API requests. It also offers convenience methods for API requests used across multiple payment methods / modules.
public class APIClient {

    private var http: HTTP
    private let sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    private let coreConfig: CoreConfig

    public init(coreConfig: CoreConfig) {
        self.http = HTTP(coreConfig: coreConfig)
        self.coreConfig = coreConfig
    }

    /// For internal use for testing purpose
    init(urlSession: URLSessionProtocol, coreConfig: CoreConfig) {
        self.http = HTTP(urlSession: urlSession, coreConfig: coreConfig)
        self.coreConfig = coreConfig
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func fetch<T: APIRequest>(request: T) async throws -> (T.ResponseType) {
        return try await http.performRequest(request)
    }

    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func getClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(request)
        return response.clientID
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendAnalyticsEvent(_ name: String) async {
        let eventData = AnalyticsEventData(eventName: name, sessionID: sessionID)

        do {
            let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
            let (_) = try await http.performRequest(analyticsEventRequest)
        } catch let error {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
