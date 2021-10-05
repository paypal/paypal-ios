import Foundation

public final class APIClient {
    public typealias CorrelationID = String

    public var urlSession: URLSession
    public var environment: Environment

    private let decoder = JSONDecoder()

    public init(urlSession: URLSession = .shared, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func fetch<T: APIRequest>(
        endpoint: T,
        completion: @escaping (Result<T.ResponseType, NetworkingError>, CorrelationID?) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            completion(.failure(.noURLRequest), nil)
            return
        }

        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.connectionIssue(error)), nil)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidURLResponse), nil)
                return
            }

            guard let data = data else {
                completion(.failure(.noResponseData), nil)
                return
            }

            let correlationID = response.allHeaderFields["Paypal-Debug-Id"] as? String

            switch response.statusCode {
            case 200..<300:
                do {
                    // TODO: Get rid of this empty case, relevant tests, & files.
                    if let emptyResponse = EmptyResponse() as? T.ResponseType {
                        completion(.success(emptyResponse), correlationID)
                    } else {
                        let decodedData = try self.decoder.decode(T.ResponseType.self, from: data)
                        completion(.success(decodedData), correlationID)
                    }
                } catch let networkingError as NetworkingError {
                    completion(.failure(networkingError), correlationID)
                } catch {
                    // TODO: Returning this error will always be nil at this point
                    completion(.failure(.parsingError(error)), correlationID)
                }

            default:
                // TODO:
                // Add networking error cases (ie more descriptive networking errors / handle 400 responses, 500 errors, etc
                completion(.failure(.unknown), nil)
            }
        }

        task.resume()
    }

}
