import Foundation

final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()

    private init() {}

    func createOrder(orderParams: CreateOrderParams, completion: @escaping ((Result<Order, URLResponseError>) -> Void)) {
        // TODO: get environment from settings in Demo app
        guard let url = URL(string: DemoSettings.Environment.sandbox.baseURL + "/order?countryCode=US") else {
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

    func processOrder(processOrderParams: ProcessOrderParams, completion: @escaping ((Result<Order, URLResponseError>) -> Void)) {
        // TODO: get environment from settings in Demo app
        guard let url = URL(string: DemoSettings.Environment.sandbox.baseURL
                            + "/\(processOrderParams.intent)-order") else {
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
