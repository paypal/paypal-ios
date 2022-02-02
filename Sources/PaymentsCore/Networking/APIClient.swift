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

    public func fetchAsync<T: APIRequest>(endpoint: T) async throws -> (T.ResponseType, CorrelationID?) {
        guard let urlSession = urlSession as? URLSession else { throw NSError() }
        guard let request = endpoint.toURLRequest(environment: environment) else { throw NSError() }

        do {
            let (data, response) = try await urlSession.data(for: request)
            let correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String

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
                do {
                    let errorData = try self.decoder.decode(ErrorResponse.self, from: data)
                    throw APIClientError.serverResponseError(errorData.readableDescription)
                } catch {
                    throw APIClientError.unknownError
                }
            }
        } catch {
            throw APIClientError.urlSessionError(error.localizedDescription)
        }
    }

    public func fetch<T: APIRequest>(
        endpoint: T,
        completion: @escaping (Result<T.ResponseType, PayPalSDKError>, CorrelationID?) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            completion(.failure(APIClientError.invalidURLRequestError), nil)
            return
        }

        urlSession.performRequest(with: request) { data, response, error in
            let correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String

            if let error = error {
                completion(.failure(APIClientError.urlSessionError(error.localizedDescription)), correlationID)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(APIClientError.invalidURLResponseError), correlationID)
                return
            }

            guard let data = data else {
                completion(.failure(APIClientError.noResponseDataError), correlationID)
                return
            }

            switch response.statusCode {
            case 200..<300:
                do {
                    let decodedData = try self.decoder.decode(T.ResponseType.self, from: data)
                    completion(.success(decodedData), correlationID)
                } catch {
                    completion(.failure(APIClientError.dataParsingError), correlationID)
                }
            default:
                do {
                    let errorData = try self.decoder.decode(ErrorResponse.self, from: data)
                    completion(.failure(APIClientError.serverResponseError(errorData.readableDescription)), correlationID)
                } catch {
                    completion(.failure(APIClientError.unknownError), correlationID)
                }
            }
        }
    }
}

protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: URLSessionProtocol {

    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }
}

extension URLSession {

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
