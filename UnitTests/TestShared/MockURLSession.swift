import Foundation
@testable import CorePayments

class MockURLSession: URLSessionProtocol {

    var cannedError: Error?
    var cannedURLResponse: URLResponse?
    var cannedJSONData: String?
    
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if let error = cannedError {
            throw error
        } else {
            let data = cannedJSONData?.data(using: String.Encoding.utf8) ?? Data()
            let urlResponse = cannedURLResponse ?? HTTPURLResponse()
            return (data, urlResponse)
        }
    }
}
