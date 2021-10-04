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
            let finish: (Result<T.ResponseType, NetworkingError>) -> Void = { result in
                /// For discussion:
                /// When a network request to a PayPal API fails, we have some associated error information in the body data of the response.
                /// This error data doesn't have the same format, but we should discuss and plan for how we want to surface this to the merchant
                let httpResponse = response as? HTTPURLResponse
                let correlationID = httpResponse?.allHeaderFields["Paypal-Debug-Id"] as? String
                completion(result, correlationID)
            }

            if let error = error {
                finish(.failure(.connectionIssue(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                finish(.failure(.invalidURLResponse))
                return
            }

            switch response.statusCode {
            case 200..<300:
                do {
                    if let emptyResponse = EmptyResponse() as? T.ResponseType {
                        finish(.success(emptyResponse))
                    } else {
                        let responseType = try self.parseDataObject(data, type: T.self)
                        finish(.success(responseType))
                    }
                } catch let networkingError as NetworkingError {
                    finish(.failure(networkingError))
                } catch {
                    finish(.failure(.parsingError(error)))
                }

            default:
                // TODO:
                // Add networking error cases (ie more descriptive networking errors / handle 400 responses, 500 errors, etc
                finish(.failure(.unknown))
            }
        }

        task.resume()
    }

    func parseDataObject<T: APIRequest>(_ data: Data?, type: T.Type) throws -> T.ResponseType {
        guard let data = data else {
            throw NetworkingError.noResponseData
        }
        let decodedData = try decoder.decode(T.ResponseType.self, from: data)
        return decodedData
    }
}
