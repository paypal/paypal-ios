import Foundation

class AnalyticsClient {
    
    private let sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    private let decoder = APIClientDecoder()

    static let shared = AnalyticsClient()
    
    
    private init() {}
    
    func sendEvent(name: String) {
        // do stuff
    }
}
