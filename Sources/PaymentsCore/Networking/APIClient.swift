import Foundation

public final class APIClient {

    public typealias CorrelationID = String

    private var urlSession: URLSessionProtocol
    private var environment: Environment

    private let decoder = APIClientDecoder()

    public init(environment: Environment) {
        self.environment = environment
        self.urlSession = URLSession.shared
    }

    /// For internal use for testing purpose
    init(urlSession: URLSessionProtocol, environment: Environment) {
        self.environment = environment
        self.urlSession = urlSession
    }

    public func fetch<T: APIRequest>(endpoint: T) async throws -> (T.ResponseType, CorrelationID?) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
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
}

class APIClientDecoder {

    private let decoder: JSONDecoder

    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func decode<T: APIRequest>(_ type: T.Type, from data: Data) throws -> T.ResponseType {
        do {
            return try self.decoder.decode(T.ResponseType.self, from: data)
        } catch {
            throw APIClientError.dataParsingError
        }
    }

    func decode(from data: Data) throws -> ErrorResponse {
        do {
            return try self.decoder.decode(ErrorResponse.self, from: data)
        } catch {
            throw APIClientError.unknownError
        }
    }
}
