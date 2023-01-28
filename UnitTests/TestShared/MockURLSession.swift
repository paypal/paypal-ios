import Foundation
@testable import PaymentsCore

class MockURLSession: URLSessionProtocol {

    var cannedError: Error?
    var cannedURLResponse: URLResponse?
    var cannedJSONData: String?
    
    var lastURLRequestPerformed: URLRequest?

    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        lastURLRequestPerformed = urlRequest
        
        if let error = cannedError {
            throw error
        } else {
            let data = cannedJSONData?.data(using: String.Encoding.utf8) ?? Data()
            let urlResponse = cannedURLResponse ?? HTTPURLResponse()
            return (data, urlResponse)
        }
    }
}
