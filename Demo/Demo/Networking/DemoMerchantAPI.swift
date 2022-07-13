import Foundation
import PaymentsCore

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()
    
    var accessToken: String? = nil

    private init() {}

    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderParams: CreateOrderParams) async throws -> Order {
        guard let url = buildBaseURL(with: "/order?countryCode=US") else {
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
    
    public func getAccessToken(clientId: String, environment: PaymentsCore.Environment) async -> String?{
        guard let token = self.accessToken else{
            self.accessToken = await fetchAccessToken(clientId: clientId, environment: environment)
            return self.accessToken
        }
        return token
    }
    
    private func fetchAccessToken(clientId: String, environment: PaymentsCore.Environment) async -> String? {
        do {
            let accessTokenRequest = AccessTokenRequest(clientID: clientId)
            guard let request = accessTokenRequest.toURLRequest(environment: environment) else {
                throw URLResponseError.dataParsingError
            }
            let (data, response) = try await URLSession.shared.performRequest(with: request)
            guard let response = response as? HTTPURLResponse else {
                throw URLResponseError.networkConnectionError
            }
            switch response.statusCode {
                case 200..<300:
                    let accessTokenResponse: AccessTokenResponse = try parse(from: data)
                    return accessTokenResponse.accessToken
            default: throw URLResponseError.serverError
            }
        }
        catch{
            print("Error in fetching token")
            return nil
        }
    }
    
}
