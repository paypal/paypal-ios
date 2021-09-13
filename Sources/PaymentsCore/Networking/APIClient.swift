import Foundation

public class APIClient {

    public var urlSession: URLSession
    public var environment: Environment

    public init(urlSession: URLSession = .shared, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }

    public func fetch<T: Codable>(
        endpoint: APIRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let request = endpoint.toURLRequest(environment: environment) else {
            // TODO: return an error
            return
        }

        let task = urlSession.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            // TODO: add all of the status codes
            switch response.statusCode {
            case 200..<300:

                guard let data = data else {
                    // no data
                    return
                }

                // decode T from data
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                    return
                }
                catch let decodingError {
                    completion(.failure(decodingError))
                    return
                }

                // success

            default:
                completion(.failure(SDKError.networkingError))
                return
            }
        }

        task.resume()
    }

    // TODO: add fetch JSON request
}
