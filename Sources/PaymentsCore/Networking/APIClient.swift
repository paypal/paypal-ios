import Foundation

public class APIClient {

    public typealias CorrelationID = String

    private var urlSession: URLSessionProtocol
    private let coreConfig: CoreConfig
    private let sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    private let decoder = APIClientDecoder()

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.urlSession = URLSession.shared
    }

    /// For internal use for testing purpose
    init(urlSession: URLSessionProtocol, coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.urlSession = urlSession
    }

    public func fetch<T: APIRequest>(endpoint: T) async throws -> (T.ResponseType, CorrelationID?) {
        guard let request = endpoint.toURLRequest(environment: coreConfig.environment) else {
            throw APIClientError.invalidURLRequestError
        }
        // TODO: consider throwing PayPalError from perfomRequest
        let (data, response) = try await urlSession.performRequest(with: request)
        let correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }

        switch response.statusCode {
        case 200..<300:
            let decodedData = try decoder.decode(T.self, from: data)
            return (decodedData, correlationID)
        default:
            let errorData = try decoder.decode(from: data)
            throw APIClientError.serverResponseError(errorData.readableDescription)
        }
    }

    public func getClientID() async throws -> String {
        let request = GetClientIDRequest(accessToken: coreConfig.accessToken)
        let (response, _) = try await fetch(endpoint: request)
        return response.clientID
    }
    
    /// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendAnalyticsEvent(_ name: String) async {
        let analyticsPayload = AnalyticsEventData(eventName: name, sessionID: sessionID)

        do {
            let analyticsEventRequest = try AnalyticsEventRequest(payload: analyticsPayload)
            let (_, _) = try await fetch(endpoint: analyticsEventRequest)
        } catch let error {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
