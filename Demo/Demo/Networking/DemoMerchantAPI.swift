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

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            do {
                return try JSONDecoder().decode(Order.self, from: data)
            } catch {
                throw URLResponseError.dataParsingError
            }
        } catch {
            throw URLResponseError.networkConnectionError
        }
    }

    /// This function replicates a way a merchant may go about authorizing/capturing an order on their server and is not part of the SDK flow.
    /// - Parameters:
    ///   - processOrderParams: the parameters to process the order with
    /// - Returns: a result object vending either the order or an error
    func processOrder(processOrderParams: ProcessOrderParams) async throws -> Order {
        guard let url = buildBaseURL(with: "/\(processOrderParams.intent)-order") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(processOrderParams)

        var data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw URLResponseError.networkConnectionError
        }
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
