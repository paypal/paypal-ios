import Foundation

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()

    private init() {}

    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - orderParams: the parameters to create the order with
    ///   - completion: a result object vending either the order or an error
    func createOrder(orderParams: CreateOrderParams, completion: @escaping ((Result<Order, URLResponseError>) -> Void)) {
        // TODO: get environment from settings in Demo app
        guard let url = URL(string: DemoSettings.environment.baseURL + "/order?countryCode=US") else {
            completion(.failure(.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try? encoder.encode(orderParams)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkConnectionError))
                return
            }

            if response == nil {
                completion(.failure(.serverError))
                return
            }

            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(.success(order))
            } catch {
                completion(.failure(.dataParsingError))
            }
        }
        .resume()
    }

    /// This function replicates a way a merchant may go about authorizing/capturing an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - processOrderParams: the parameters to process the order with
    ///   - completion: a result object vending either the order or an error
    func processOrder(processOrderParams: ProcessOrderParams, completion: @escaping ((Result<Order, URLResponseError>) -> Void)) {
        // TODO: finalize functionality once we add approve order/card module
        // TODO: get environment from settings in Demo app
        let url = URL(string: DemoSettings.environment.baseURL + "/\(processOrderParams.intent)-order")
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(processOrderParams)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkConnectionError))
                return
            }

            if response == nil {
                completion(.failure(.serverError))
                return
            }

            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(.success(order))
            } catch {
                completion(.failure(.dataParsingError))
            }
        }
        .resume()
    }
}
