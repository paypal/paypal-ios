import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
public class AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let http: HTTP
    private let orderID: String
        
    // MARK: - Initializer
    
    /// This initializer is private to enforce the singleton pattern. An instance of `AnalyticsService` cannot be instantiated outside this file.
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.http = HTTP(coreConfig: coreConfig)
        self.orderID = orderID
        // TODO: - Make init async, or throw if clientID not found
    }
    
    // MARK: - Public Methods
        
    public func sendEvent(_ name: String) {
        Task {
            do {
                let clientID = try await fetchCachedOrRemoteClientID()
            } catch {
                NSLog("[PayPal SDK] Failed to send analytics due to missing clientID: %@", error.localizedDescription.debugDescription)
            }
        }
        
        // TODO: - block sending event until clientID fetched
        
        let eventData = AnalyticsEventData(
            environment: http.coreConfig.environment.toString,
            eventName: name,
            clientID: "clientID",
            sessionID: orderID
        )
        
        Task(priority: .background) {
            do {
                let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
                let (_) = try await http.performRequest(analyticsEventRequest)
            } catch {
                NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
            }
        }
    }
    
    private func fetchCachedOrRemoteClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response) = try await http.performRequest(request, withCaching: true)
        return response.clientID
    }
}
