import Foundation

class AnalyticsService {

    // MARK: - Internal Properties

    private let http: HTTP
    let sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")

    // MARK: - Initializer

    init(http: HTTP) {
        self.http = http
    }
    
    // MARK: - Internal Methods

    func sendEvent(_ name: String) async {
        let eventData = AnalyticsEventData(eventName: name, sessionID: sessionID)

        do {
            let analyticsEventRequest = try AnalyticsEventRequest(eventData: eventData)
            let (_) = try await http.performRequest(endpoint: analyticsEventRequest)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
