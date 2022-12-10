import Foundation
@testable import PaymentsCore

// swiftlint:disable force_unwrapping redundant_optional_initialization
class MockURLSession: URLSessionProtocol {
    
    // Set default response value to URL 200 success
    var cannedError: Error? = nil
    var cannedURLResponse = HTTPURLResponse(
        url: URL(string: "www.fake-url.com")!,
        statusCode: 200,
        httpVersion: "https",
        headerFields: [:]
    )
    var cannedJSONData: String? = ""

    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if let error = cannedError {
            throw error
        } else {
            guard let data = cannedJSONData.data(using: String.Encoding.utf8) else { fatalError("error") }
            guard let urlResponse = cannedURLResponse else { fatalError("error") }
            return (data, urlResponse)
        }
    }
}
