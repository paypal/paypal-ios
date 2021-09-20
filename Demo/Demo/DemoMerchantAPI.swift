import Foundation

enum Environment {
    case sandbox, production
    
    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://ppcp-sample-merchant-sand.herokuapp.com")!
        case .production:
            return URL(string: "https://ppcp-sample-merchant-prod.herokuapp.com")!
        }
    }
}

final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()
    
    private init() {}

    func createOrder(orderParams: CreateOrderParams, completion: @escaping ((Order?, Error?) -> Void)) {
        // TODO: get environment from settings in Demo app
        var components = URLComponents(url: Environment.sandbox.baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/order"
        components.queryItems = [URLQueryItem(name: "countryCode", value: "US")]

        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try! encoder.encode(orderParams)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error!)
                return
            }

            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(order, nil)
            } catch (let parseError) {
                completion(nil, parseError)
            }
        }.resume()
    }

    func processOrder(processOrderParams: ProcessOrderParams, completion: @escaping ((Order?, Error?) -> Void)) {
        // TODO: get environment from settings in Demo app
        var components = URLComponents(url: Environment.sandbox.baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/\(processOrderParams.intent.lowercased())-order" // TODO: does case matter?

        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONEncoder().encode(processOrderParams)

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error!)
                return
            }

            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(order, nil)
            } catch (let parseError) {
                completion(nil, parseError)
            }
        }.resume()
    }
}
