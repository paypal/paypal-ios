import Foundation

protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}
