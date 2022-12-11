import Foundation

class AnalyticsService {
    
    // MARK: - Internal Properties

    private static let instance = AnalyticsService()
    
    var sessionID = ""
    
    private var http: HTTP? {
        willSet {
            if newValue?.coreConfig.accessToken != http?.coreConfig.accessToken {
                sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            }
        }
    }
        
    // MARK: - Initializer
    
    private init() { }
    
    // MARK: - Internal Methods
    
    public static func sharedInstance(http: HTTP) -> AnalyticsService {
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
