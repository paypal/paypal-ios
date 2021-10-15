
import UIKit
@testable import PaymentsCore

class MockHTTPClient: HTTP {
    
    // MARK: - Properties
    private var defaultSendStub: HTTPResponse?
    private var pendingCallback: ((HTTPResponse) -> Void)?
    
    private(set) var lastSentRequest: URLRequest?
    
    // MARK: - HTTP
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPResponse) -> Void) {
        lastSentRequest = urlRequest
        if let stub = defaultSendStub {
            completion(stub)
        } else {
            pendingCallback = completion
        }
    }
    
    // MARK: - MockHTTPClient
    func stubSend(with httpResponse: HTTPResponse) {
        defaultSendStub = httpResponse
    }
}
