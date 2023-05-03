import Foundation

/// :nodoc: Constructs `AnalyticsEventData` models and sends FPTI analytics events.
public class AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let http: HTTP
    private let orderID: String
        
    // MARK: - Initializer
    
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.http = HTTP(coreConfig: coreConfig)
        self.orderID = orderID
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, http: HTTP) {
        self.coreConfig = coreConfig
        self.http = http
        self.orderID = orderID
    }
    
    // MARK: - Public Methods
        
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendEvent(_ name: String) {
        Task(priority: .background) {
            await performEventRequest(name)
        }
    }
    
    /// :nodoc: Exposed for testing only.
    ///
    /// Blocking version of the `sendEvent` function. Allows easy unit testing of asychronous code.
    func sendEvent(_ name: String) async {
        await performEventRequest(name)
    }
    
    // MARK: - Private Methods
    
    private func performEventRequest(_ name: String) async {
        do {
            let clientID = try await fetchCachedOrRemoteClientID()
            
            let eventData = AnalyticsEventData(
                environment: http.coreConfig.environment.toString,
                eventName: name,
                clientID: clientID,
                orderID: orderID
            )
            
            let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
            let (_) = try await http.performRequest(analyticsEventRequest)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
    
    private func fetchCachedOrRemoteClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(request, withCaching: true)
        return response.clientID
    }
}
