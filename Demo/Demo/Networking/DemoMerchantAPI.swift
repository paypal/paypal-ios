import Foundation
import CorePayments

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    /// Merchant endpoints, which differ per environment: the Live merchant proxies the PayPal
    /// REST API, while the sandbox sample server exposes its own shorthand routes.
    private enum Endpoint {

        case orders
        case orderCapture(orderID: String)
        case orderAuthorize(orderID: String)
        case setupTokens
        case paymentTokens

        func path(for environment: DemoEnvironment) -> String {
            environment.usesPayPalRESTContract ? restPath : sandboxPath
        }

        private var sandboxPath: String {
            switch self {
            case .orders: return "/orders"
            case .orderCapture(let orderID): return "/orders/\(orderID)/capture"
            case .orderAuthorize(let orderID): return "/orders/\(orderID)/authorize"
            case .setupTokens: return "/setup-tokens"
            case .paymentTokens: return "/payment-tokens"
            }
        }

        private var restPath: String {
            switch self {
            case .orders: return "/v2/checkout/orders"
            case .orderCapture(let orderID): return "/v2/checkout/orders/\(orderID)/capture"
            case .orderAuthorize(let orderID): return "/v2/checkout/orders/\(orderID)/authorize"
            case .setupTokens: return "/v3/vault/setup-tokens"
            case .paymentTokens: return "/v3/vault/payment-tokens"
            }
        }
    }

    static let sharedService = DemoMerchantAPI()

    // To hardcode an order ID and client ID for this demo app, set the below values
    enum InjectedValues {
        static let orderID: String? = nil
        static let clientID: String? = nil
    }

    private init() {}

    func createSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration,
        paymentSourceType: PaymentSourceType
    ) async throws -> CreateSetupTokenResponse {
        do {
            let requestBody = CreateSetupTokenParam(customer: VaultCustomer(id: customerID), paymentSource: paymentSourceType)

            guard let url = buildURL(for: .setupTokens) else {
                throw URLResponseError.invalidURL
            }
            // make it mutable to add header fields for partner scenarios
            let request = buildURLRequest(method: "POST", url: url, body: requestBody)
            let data = try await data(for: request)
            return try parse(from: data)
        } catch {
            throw error
        }
    }

    func createPaymentToken(setupToken: String, selectedMerchantIntegration: MerchantIntegration) async throws -> PaymentTokenResponse {
        do {
            let requestBody = PaymentTokenParam(paymentSource: PaymentTokenParam.PaymentSource(setupTokenID: setupToken))
            guard let url = buildURL(for: .paymentTokens) else {
                throw URLResponseError.invalidURL
            }
            // make it mutable to add header value for partner scenarios
            let request = buildURLRequest(method: "POST", url: url, body: requestBody)

            let data = try await data(for: request)
            return try parse(from: data)
        } catch {
            print("error with the create payment token request: \(error.localizedDescription)")
            throw error
        }
    }

    func completeOrder(intent: Intent, orderID: String, payPalClientMetadataID: String? = nil) async throws -> Order {
        let endpoint: Endpoint = intent == .authorize
            ? .orderAuthorize(orderID: orderID)
            : .orderCapture(orderID: orderID)
        guard let url = buildURL(for: endpoint) else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        if let payPalClientMetadataID {
            urlRequest.addValue(payPalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
        }
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    func captureOrder(
        orderID: String,
        selectedMerchantIntegration: MerchantIntegration,
        payPalClientMetadataID: String? = nil
    ) async throws -> Order {
        guard let url = buildURL(for: .orderCapture(orderID: orderID)) else {
            throw URLResponseError.invalidURL
        }
        
        var urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        if let payPalClientMetadataID {
            urlRequest.addValue(payPalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
        }
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }
    
    func authorizeOrder(
        orderID: String,
        selectedMerchantIntegration: MerchantIntegration,
        payPalClientMetadataID: String? = nil
    ) async throws -> Order {
        guard let url = buildURL(for: .orderAuthorize(orderID: orderID)) else {
            throw URLResponseError.invalidURL
        }
        
        var urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        if let payPalClientMetadataID {
            urlRequest.addValue(payPalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
        }
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }
    
    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderParams: CreateOrderParams, selectedMerchantIntegration: MerchantIntegration) async throws -> Order {
        if let injectedOrderID = InjectedValues.orderID {
            return Order(id: injectedOrderID, status: "CREATED")
        }
        guard let url = buildURL(for: .orders) else {
            throw URLResponseError.invalidURL
        }

        let urlRequest = buildURLRequest(method: "POST", url: url, body: orderParams)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    /// This function fetches a clientID to initialize any module of the SDK
    /// - Parameters:
    ///   - environment: the current environment
    /// - Returns: a String representing an clientID
    /// - Throws: an error explaining why fetch clientID failed
    public func getClientID(environment: DemoEnvironment, selectedMerchantIntegration: MerchantIntegration) async -> String? {
        if let injectedClientID = InjectedValues.clientID {
            return injectedClientID
        }

        #if DEBUG
        if environment == .custom {
            return DemoSettings.customEnvironment?.clientID
        }
        #endif

        return selectedMerchantIntegration.clientID
    }

    // MARK: Private methods

    private func buildURLRequest<T>(method: String, url: URL, body: T) -> URLRequest where T: Encodable {
        let encoder = JSONEncoder()
        if DemoSettings.environment.usesPayPalRESTContract {
            encoder.keyEncodingStrategy = .convertToSnakeCase
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if method != "GET", let json = try? encoder.encode(body) {
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
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw URLResponseError.dataParsingError
        }
    }

    private func buildURL(for endpoint: Endpoint) -> URL? {
        let environment = DemoSettings.environment
        return URL(string: environment.baseURL + endpoint.path(for: environment))
    }

    private func buildPayPalURL(with endpoint: String) -> URL? {
        URL(string: "https://api.sandbox.paypal.com" + endpoint)
    }

    private func fetchClientID(environment: DemoEnvironment, selectedMerchantIntegration: MerchantIntegration) async -> String? {
        do {
            let clientIDRequest = ClientIDRequest()
            let request = try createUrlRequest(
                clientIDRequest: clientIDRequest, environment: environment, selectedMerchantIntegration: selectedMerchantIntegration
            )
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
    
    private func createUrlRequest(
        clientIDRequest: ClientIDRequest,
        environment: DemoEnvironment,
        selectedMerchantIntegration: MerchantIntegration
    ) throws -> URLRequest {
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
