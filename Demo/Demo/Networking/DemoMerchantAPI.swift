import Foundation
import CorePayments
import PayPalCheckout

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    // MARK: Public properties

    static let sharedService = DemoMerchantAPI()
    var clientID: String?
    
    // To hardcode an order ID and client ID for this demo app, set the below values
    enum InjectedValues {
        static let orderID: String? = nil
        static let clientID: String? = nil
    }

    private init() {}

    // MARK: Public Methods
    
    func caputureOrder(orderID: String) async throws -> Order {
        guard let url = buildBaseURL(with: "/orders/\(orderID)/capture") else {
            throw URLResponseError.invalidURL
        }
        
        let urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }
    
    func authorizeOrder(orderID: String) async throws -> Order {
        guard let url = buildBaseURL(with: "/orders/\(orderID)/authorize") else {
            throw URLResponseError.invalidURL
        }
        
        let urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }
    
    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderParams: CreateOrderParams) async throws -> Order {
        if let injectedOrderID = InjectedValues.orderID {
            return Order(id: injectedOrderID, status: "CREATED")
        }
        
        guard let url = buildBaseURL(with: "/orders") else {
            throw URLResponseError.invalidURL
        }

        let urlRequest = buildURLRequest(method: "POST", url: url, body: orderParams)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    /// This function replicates a way a merchant may go about creating an order on their server using PayPalNative order request object
    /// - Parameter orderRequest: the order request to create an order
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderRequest: PayPalCheckout.OrderRequest) async throws -> Order {
        if let injectedOrderID = InjectedValues.orderID {
            return Order(id: injectedOrderID, status: "CREATED")
        }
        guard let url = buildBaseURL(with: "/orders") else {
            throw URLResponseError.invalidURL
        }

        let urlRequest = buildURLRequest(method: "POST", url: url, body: orderRequest)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    /// This function replicates a way a merchant may go about authorizing/capturing an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - processOrderParams: the parameters to process the order with
    /// - Returns: an order
    /// - Throws: an error explaining why process order failed
    func processOrder(processOrderParams: ProcessOrderParams) async throws -> Order {
        guard let url = buildBaseURL(with: "/\(processOrderParams.intent)-order") else {
            throw URLResponseError.invalidURL
        }

        let urlRequest = buildURLRequest(method: "POST", url: url, body: processOrderParams)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }
    
    /// This function replicates a way a merchant may go about patching an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - updateOrderParams: the parameters to update the order with
    /// - Throws: an error explaining why patching the order failed
    func updateOrder(_ updateOrderParams: UpdateOrderParams) async throws {
        guard let url = buildBaseURL(with: "/orders/" + updateOrderParams.orderID) else {
            throw URLResponseError.invalidURL
        }
        let urlRequest = buildURLRequest(method: "PATCH", url: url, body: updateOrderParams.updateOperations)
        _ = try await data(for: urlRequest)
    }

    /// This function fetches a clientID to initialize any module of the SDK
    /// - Parameters:
    ///   - environment: the current environment
    /// - Returns: a String representing an clientID
    /// - Throws: an error explaining why fetch clientID failed
    public func getClientID(environment: Demo.Environment) async -> String? {
        if let injectedClientID = InjectedValues.clientID {
            return injectedClientID
        }
        
        guard let clientID else {
            clientID = await fetchClientID(environment: environment)
            return clientID
        }
        return clientID
    }

    // MARK: Private methods

    private func buildURLRequest<T>(method: String, url: URL, body: T) -> URLRequest where T: Encodable {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let json = try? encoder.encode(body) {
            print(String(data: json, encoding: .utf8) ?? "")
            urlRequest.httpBody = json
        }

        return urlRequest
    }

    private func data(for urlRequest: URLRequest) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            return data
        } catch {
            throw URLResponseError.networkConnectionError
        }
    }

    private func parse<T: Decodable>(from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw URLResponseError.dataParsingError
        }
    }

    private func buildBaseURL(with endpoint: String) -> URL? {
        URL(string: DemoSettings.environment.baseURL + endpoint)
    }

    private func buildPayPalURL(with endpoint: String) -> URL? {
        URL(string: "https://api.sandbox.paypal.com" + endpoint)
    }

    private func fetchClientID(environment: Demo.Environment) async -> String? {
        do {
            let clientIDRequest = ClientIDRequest()
            let request = try createUrlRequest(clientIDRequest: clientIDRequest, environment: environment)
            let (data, response) = try await URLSession.shared.performRequest(with: request)
            guard let response = response as? HTTPURLResponse else {
                throw URLResponseError.serverError
            }
            switch response.statusCode {
            case 200..<300:
                let clientIDResponse: ClientIDResponse = try parse(from: data)
                return clientIDResponse.clientID
            default: throw URLResponseError.dataParsingError
            }
        } catch {
            print("Error in fetching clientID")
            return nil
        }
    }
    
    private func createUrlRequest(clientIDRequest: ClientIDRequest, environment: Demo.Environment) throws -> URLRequest {
        var completeUrl = environment.baseURL
        completeUrl.append(contentsOf: clientIDRequest.path)
        guard let url = URL(string: completeUrl) else {
            throw URLResponseError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = clientIDRequest.method.rawValue
        request.httpBody = clientIDRequest.body
        clientIDRequest.headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        return request
    }
}
