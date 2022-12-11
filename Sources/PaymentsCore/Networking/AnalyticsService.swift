import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
class AnalyticsService {
    
    // MARK: - Internal Properties

    private static let instance = AnalyticsService()
    
    var sessionID = ""
    
    private var http: HTTP? {
        // This property observer generates a new `sessionID` if the `accessToken`
        // injected into the `AnalyticsSingleton` ever changes.
        willSet {
            if newValue?.coreConfig.accessToken != http?.coreConfig.accessToken {
                sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            }
        }
    }
        
    // MARK: - Initializer
    
    /// This initializer is private to enforce the singleton pattern. An instance of `AnalyticsService` cannot be instantiated outside this file.
    private init() { }
    
    // MARK: - Internal Methods
    
    /// Used to access the singleton instance of `AnalyticsService`.
    static func sharedInstance(http: HTTP) -> AnalyticsService {
        instance.http = http
        return instance
    }
        
    func sendEvent(_ name: String) async {
        let eventData = AnalyticsEventData(eventName: name, sessionID: sessionID)
        
        do {
            let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
            let (_) = try await http?.performRequest(endpoint: analyticsEventRequest)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
