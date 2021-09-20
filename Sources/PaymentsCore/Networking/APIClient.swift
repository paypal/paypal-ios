import Foundation

public class APIClient {
    public typealias CorrelationID = String

    public var urlSession: URLSession
    public var environment: Environment

    public init(urlSession: URLSession = .shared, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }

    public func fetch<T: APIRequest>(
        endpoint: T,
        completion: @escaping (Result<T.ResponseType?, CoreError>, CorrelationID?) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            completion(.failure(.noURLRequest), nil)
            return
        }

        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else { return }
            let correlationID = response.allHeaderFields["Paypal-Debug-Id"] as? String

            let finish: (Result<T.ResponseType?, CoreError>) -> Void = { result in
                /// For discussion:
                /// When a network request to a PayPal API fails, we have some associated error information in the body data of the response.
                /// This error data doesn't have the same format, but we should discuss and plan for how we want to surface this to the merchant
                completion(result, correlationID)
            }

            if let error = error {
                finish(.failure(.networkingError(error)))
            }

            switch response.statusCode {
            case 200..<300:
                do {
                    if T.ResponseType.self == EmptyResponse.self {
                        finish(.success(nil))
                    } else {
                        guard let data = data else {
                            finish(.failure(.noResponseData))
                            return
                        }

                        let decodedData = try JSONDecoder().decode(T.ResponseType.self, from: data)
                        finish(.success(decodedData))
                    }
                } catch let decodingError {
                    finish(.failure(.decodingError(decodingError)))
                }

            default:
                // TODO:
                // Add networking error cases (ie more descriptive networking errors / handle 400 responses, 500 errors, etc
                finish(.failure(.unknown))
            }
        }

        task.resume()
    }
}
