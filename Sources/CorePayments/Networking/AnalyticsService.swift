import Foundation

/// :nodoc: Constructs `AnalyticsEventData` models and sends FPTI analytics events.
public struct AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let apiClient: APIClient
    private let orderID: String
        
    // MARK: - Initializer
    
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.apiClient = APIClient(coreConfig: CoreConfig(clientID: coreConfig.clientID, environment: .live))
        self.orderID = orderID
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, apiClient: APIClient) {
        self.coreConfig = coreConfig
        self.apiClient = apiClient
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
    
    // MARK: - Internal Methods
    
    func performEventRequest(_ name: String) async {
        do {
            let clientID = coreConfig.clientID
            
            let eventData = AnalyticsEventData(
                environment: coreConfig.environment.toString,
                eventName: name,
                clientID: clientID,
                orderID: orderID
            )
            
            let (_) = try await TrackingEventsAPI().sendEvent(with: eventData)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}

class TrackingEventsAPI {
        
    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        let apiClient = APIClient(coreConfig: CoreConfig(clientID: analyticsEventData.clientID, environment: .live))
        
        // encode the body -- todo move
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(analyticsEventData) // handle with special
        
        let restRequest = RESTRequest(
            path: "v1/tracking/events",
            method: .post,
            headers: [.contentType: "application/json"],
            queryParameters: nil,
            body: body
        )
        
        return try await apiClient.fetch(request: restRequest)
        // skip HTTP parsing!
    }
}
