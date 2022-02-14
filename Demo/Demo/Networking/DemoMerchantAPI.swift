import Foundation

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()

    private init() {}

    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order or throws an error
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
        return try parseOrder(from: data)
    }

    /// This function replicates a way a merchant may go about authorizing/capturing an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - processOrderParams: the parameters to process the order with
    /// - Returns: an order or throws an error
    func processOrder(processOrderParams: ProcessOrderParams) async throws -> Order {
        guard let url = buildBaseURL(with: "/\(processOrderParams.intent)-order") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(processOrderParams)

        let data = try await data(for: urlRequest)
        return try parseOrder(from: data)
    }

    private func data(for urlRequest: URLRequest) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            return data
        } catch {
            throw URLResponseError.networkConnectionError
        }
    }

    private func parseOrder(from data: Data) throws -> Order {
        do {
            return try JSONDecoder().decode(Order.self, from: data)
        } catch {
            throw URLResponseError.dataParsingError
        }
    }

    private func buildBaseURL(with endpoint: String) -> URL? {
        URL(string: DemoSettings.environment.baseURL + endpoint)
    }
}
