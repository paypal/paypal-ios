import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
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
    public func sendAnalyticsEvent(_ name: String) {
        Task {
            do {
                let clientID = try await fetchCachedOrRemoteClientID()
                await sendEvent(name, clientID: clientID)
            } catch {
                NSLog("[PayPal SDK] Failed to send analytics due to missing clientID: %@", error.localizedDescription.debugDescription)
            }
        }
    }
    
    /// Exposed for testing
    func sendAnalyticsEvent(_ name: String) async {
        do {
            let clientID = try await fetchCachedOrRemoteClientID()
            await sendEvent(name, clientID: clientID)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics due to missing clientID: %@", error.localizedDescription.debugDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func sendEvent(_ name: String, clientID: String) async {
        let eventData = AnalyticsEventData(
            environment: http.coreConfig.environment.toString,
            eventName: name,
            clientID: clientID,
            orderID: orderID
        )
        
//        Task(priority: .background) {
            do {
                let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
                let (_) = try await http.performRequest(analyticsEventRequest)
            } catch {
                NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
            }
//        }
    }
    
    private func fetchCachedOrRemoteClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(request, withCaching: true)
        return response.clientID
    }
}
