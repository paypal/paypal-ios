import Foundation

/// :no-doc:
/// TODO
public struct AnalyticsAPI {
    
    private let apiClient: APIClient
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func sendAnalyticsEvent(name: String) async {
        let analyticsEventRequest = AnalyticsEventRequest(name: name)
        do {
            let (result, correlationID) = try await apiClient.fetch(endpoint: analyticsEventRequest)
        } catch {
            // error handling
        }
    }
}
