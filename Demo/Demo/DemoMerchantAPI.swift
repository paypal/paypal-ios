import Foundation

final class DemoMerchantAPI {
    
    static let sharedService = DemoMerchantAPI()
    
    private init() {}
    
    func createOrder(orderParams: CreateOrderParams, completion: @escaping ((Result<Order, Error>) -> Void)) {
        // TODO: get environment from settings in Demo app
        var components = URLComponents(url: DemoSettings.Environment.sandbox.baseURL, resolvingAgainstBaseURL: false)!
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
                completion(.failure(error!))
                return
            }
            
            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(.success(order))
            } catch (let parseError) {
                completion(.failure(parseError))
            }
        }.resume()
    }
    
    func processOrder(processOrderParams: ProcessOrderParams, completion: @escaping ((Result<Order, Error>) -> Void)) {
        // TODO: get environment from settings in Demo app
        var components = URLComponents(url: DemoSettings.Environment.sandbox.baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/\(processOrderParams.intent)-order"
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONEncoder().encode(processOrderParams)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let order = try JSONDecoder().decode(Order.self, from: data)
                completion(.success(order))
            } catch (let parseError) {
                completion(.failure(parseError))
            }
        }.resume()
    }
}
