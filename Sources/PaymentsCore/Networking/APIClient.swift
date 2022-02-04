import Foundation

public final class APIClient {

    public typealias CorrelationID = String

    private var urlSession: URLSessionProtocol
    private var environment: Environment

    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

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
        
        var data: Data!
        var response: URLResponse!
        var correlationID: String?
        do {
            (data, response) = try await urlSession.performRequest(with: request)
            correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String
        } catch {
            throw APIClientError.urlSessionError(error.localizedDescription)
        }
        
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidURLResponseError
        }

        switch response.statusCode {
        case 200..<300:
            do {
                let decodedData = try self.decoder.decode(T.ResponseType.self, from: data)
                return (decodedData, correlationID)
            } catch {
                throw APIClientError.dataParsingError
            }
        default:
            var errorData: ErrorResponse!
            do {
                errorData = try self.decoder.decode(ErrorResponse.self, from: data)
            } catch {
                throw APIClientError.unknownError
            }
            throw APIClientError.serverResponseError(errorData.readableDescription)
        }
    }
}

protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {

    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }

    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await data(for: urlRequest)
    }

    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
