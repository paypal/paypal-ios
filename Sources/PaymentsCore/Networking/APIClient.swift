import Foundation

public final class APIClient {
    public typealias CorrelationID = String

    private var urlSession: URLSessionProtocol
    private var environment: Environment

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

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
        completion: @escaping (Result<T.ResponseType, NetworkingError>, CorrelationID?) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            completion(.failure(.noURLRequest), nil)
            return
        }

        urlSession.performRequest(with: request) { data, response, error in
            let correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String

            if let error = error {
                completion(.failure(.connectionIssue(error)), correlationID)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidURLResponse), correlationID)
                return
            }

            guard let data = data else {
                completion(.failure(.noResponseData), correlationID)
                return
            }

            switch response.statusCode {
            case 200..<300:
                do {
                    let decodedData = try self.decoder.decode(T.ResponseType.self, from: data)
                    completion(.success(decodedData), correlationID)
                    return
                } catch {
                    // TODO: Returning this error will always be nil at this point
                    completion(.failure(.parsingError(error)), correlationID)
                    return
                }

            default:
                // TODO:
                // Add networking error cases (ie more descriptive networking errors / handle 400 responses, 500 errors, etc
                completion(.failure(.unknown), nil)
                return
            }
        }
    }
}

public protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: URLSessionProtocol {
    public func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }
}
