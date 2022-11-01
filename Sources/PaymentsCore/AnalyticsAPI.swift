import Foundation

/// :no-doc:
/// TODO
public struct AnalyticsAPI {
    
    private let apiClient: APIClient
    // Separate HTTP (internal) from APIClient (merchant facing)?
    
    // Why does this really need an API client? Do we need merchant credentials?
    // Do we need anything on coreconfig?
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func sendAnalyticsEvent(name: String) async {
//        let analyticsEventParams = AnalyticsEventParams(eventName: name, clientID: "test", merchantID: "test", sessionID: "test")
//        let analyticsEvent = AnalyticsEvent(eventParams: analyticsEventParams)
//        let analyticsPayload = AnalyticsPayload(events: analyticsEvent)
//
//        do {
//            let analyticsEventRequest = try AnalyticsEventRequest(params: params)
//            let (result, _) = try await apiClient.fetch(endpoint: analyticsEventRequest)
//            print(result)
//        } catch {
//            // error handling
//        }
    }
}
