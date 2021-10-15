import Foundation
@testable import PaymentsCore

class MockURLSession: URLSessionProtocol {
    
    var cannedError: Error?
    var cannedURLResponse: URLResponse?
    var cannedJSONData: String?
    
    var lastPerformedRequest: URLRequest?
    
    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        lastPerformedRequest = urlRequest
        let cannedData = cannedJSONData?.data(using: String.Encoding.utf8)
        completionHandler(cannedData, cannedURLResponse, cannedError)
    }
}
