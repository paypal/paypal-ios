import Foundation
import PaymentsCore

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()
    var accessToken: String?
    private init() {}
    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderParams: CreateOrderParams) async throws -> Order {
        guard let url = buildBaseURL(with: "/orders") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try? encoder.encode(orderParams)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter order: order JSON in String format
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(order: String) async throws -> Order {
        guard let url = buildBaseURL(with: "/orders") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = Data(order.utf8)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    
    func createApprovalSessionID(accessToken: String, approvalSessionRequest: ApprovalSessionRequest) async throws -> VaultSessionID {
        guard let url = buildPayPalURL(with: "/v2/vault/payment-tokens") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try? encoder.encode(approvalSessionRequest)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    func createBillingAgreementToken(
        accessToken: String,
        billingAgremeentTokenRequest: BillingAgreementWithoutPurchaseRequest
    ) async throws -> BillingAgreementToken {
        guard let url = buildPayPalURL(with: "/v1/billing-agreements/agreement-tokens") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try? encoder.encode(billingAgremeentTokenRequest)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(processOrderParams)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
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

    public func getAccessToken(environment: Demo.Environment) async -> String? {
        guard let token = self.accessToken else {
            self.accessToken = await fetchAccessToken(environment: environment)
            return self.accessToken
        }
        return token
    }

    private func fetchAccessToken(environment: Demo.Environment) async -> String? {
        do {
            let accessTokenRequest = AccessTokenRequest()
            let request = try createUrlRequest(accessTokenRequest: accessTokenRequest, environment: environment)
            let (data, response) = try await URLSession.shared.performRequest(with: request)
            guard let response = response as? HTTPURLResponse else {
                throw URLResponseError.serverError
            }
            switch response.statusCode {
            case 200..<300:
                let accessTokenResponse: AccessTokenResponse = try parse(from: data)
                return accessTokenResponse.accessToken
            default: throw URLResponseError.dataParsingError
            }
        } catch {
            print("Error in fetching token")
            return nil
        }
    }

    private func createUrlRequest(accessTokenRequest: AccessTokenRequest, environment: Demo.Environment) throws -> URLRequest {
        var completeUrl = environment.baseURL
        completeUrl.append(contentsOf: accessTokenRequest.path)
        guard let url = URL(string: completeUrl) else {
            throw URLResponseError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = accessTokenRequest.method.rawValue
        request.httpBody = accessTokenRequest.body
        accessTokenRequest.headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        return request
    }
}
