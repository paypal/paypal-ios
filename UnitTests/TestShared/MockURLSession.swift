import Foundation
@testable import PaymentsCore

class MockURLSession: URLSessionProtocol {
    
    var cannedError: Error?
    var cannedURLResponse: URLResponse?
    var cannedData: Data?
    
    func performRequest(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completionHandler(cannedData, cannedURLResponse, cannedError)
    }
    
}
