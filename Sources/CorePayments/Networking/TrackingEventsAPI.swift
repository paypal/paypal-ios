import Foundation

/// This class coordinates networking logic for communicating with the v1/tracking/events API.
///
/// Details on this PayPal API can be found in PPaaS under Infrastructure > Experimentation > Tracking Events > v1.
class TrackingEventsAPI {
        
    // MARK: - Internal Properties

    var coreConfig: CoreConfig // exposed for testing
    private var networkingClient: NetworkingClient

    // MARK: - Initializer
    
    init(coreConfig merchantConfig: CoreConfig) {
        // api.sandbox.paypal.com does not currently send FPTI events to BigQuery/Looker
        self.coreConfig = CoreConfig(clientID: merchantConfig.clientID, environment: .live)
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }
    
    // MARK: - Internal Functions
        
    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        let restRequest = RESTRequest(
            path: "v1/tracking/events",
            method: .post,
            queryParameters: nil,
            postParameters: analyticsEventData
        )
        
        return try await networkingClient.fetch(request: restRequest)
    }
}
