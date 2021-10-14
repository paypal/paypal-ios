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
                    let errorData = try self.decoder.decode(ErrorData.self, from: data)
                    completion(.failure(APIClientError.responseError(errorData.readableDescription)), correlationID)
                }
                catch {
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
