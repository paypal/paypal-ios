import Foundation

public final class APIClient {

    public typealias CorrelationID = String

    private var urlSession: URLSessionProtocol
    private let coreConfig: CoreConfig

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
        guard var request = endpoint.toURLRequest(environment: coreConfig.environment) else {
            throw APIClientError.invalidURLRequestError
        }
        request.setValue("Bearer \(coreConfig.accessToken)", forHTTPHeaderField: "Authorization")
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
    
    public func getClientId() async throws -> String {
        let request = GetClientIdRequest(token: coreConfig.accessToken).toURLRequest(environment: coreConfig.environment)
        // TODO: consider throwing PayPalError from perfomRequest
        let (data, response) = try await urlSession.performRequest(with: request!)
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }

        switch response.statusCode {
        case 200..<300:
            let decodedData = try decoder.decode(GetClientIdRequest.self, from: data)
            return decodedData.clientId
        default:
            let errorData = try decoder.decode(from: data)
            throw APIClientError.serverResponseError(errorData.readableDescription)
        }
    }
}
