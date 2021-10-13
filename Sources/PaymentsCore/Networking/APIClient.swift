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
        completion: @escaping (Result<T.ResponseType, PayPalSDKError>, CorrelationID?) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            let error = PayPalSDKError(
                code: PaymentsCoreError.Code.noURLRequest.rawValue,
                domain: PaymentsCoreError.domain,
                errorDescription: "todo"
            )
            completion(.failure(error), nil)
            return
        }

        let task = urlSession.dataTask(with: request) { data, response, error in
            let correlationID = (response as? HTTPURLResponse)?.allHeaderFields["Paypal-Debug-Id"] as? String

            if let error = error {
                let error = PayPalSDKError(
                    code: PaymentsCoreError.Code.connectionIssue.rawValue,
                    domain: PaymentsCoreError.domain,
                    errorDescription: "todo"
                )
                completion(.failure(error), correlationID)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                let error = PayPalSDKError(
                    code: PaymentsCoreError.Code.invalidURLResponse.rawValue,
                    domain: PaymentsCoreError.domain,
                    errorDescription: "todo"
                )
                completion(.failure(error), correlationID)
                return
            }

            guard let data = data else {
                let error = PayPalSDKError(
                    code: PaymentsCoreError.Code.noURLRequest.rawValue,
                    domain: PaymentsCoreError.domain,
                    errorDescription: "todo"
                )
                completion(.failure(error), correlationID)
                return
            }

            switch response.statusCode {
            case 200..<300:
                do {
                    // TODO: Get rid of this empty case, relevant tests, & files.
                    if let emptyResponse = EmptyResponse() as? T.ResponseType {
                        completion(.success(emptyResponse), correlationID)
                        return
                    } else {
                        let decodedData = try self.decoder.decode(T.ResponseType.self, from: data)
                        completion(.success(decodedData), correlationID)
                        return
                    }
                } catch {
                    // TODO: Returning this error will always be nil at this point
                    let error = PayPalSDKError(
                        code: PaymentsCoreError.Code.parsingError.rawValue,
                        domain: PaymentsCoreError.domain,
                        errorDescription: "todo"
                    )
                    completion(.failure(error), correlationID)
                    return
                }

            default:
                // TODO:
                // Add networking error cases (ie more descriptive networking errors / handle 400 responses, 500 errors, etc
                let error = PayPalSDKError(
                    code: PaymentsCoreError.Code.unknown.rawValue,
                    domain: PaymentsCoreError.domain,
                    errorDescription: "todo"
                )
                completion(.failure(error), nil)
                return
            }
        }

        task.resume()
    }
}
