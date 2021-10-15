
import UIKit
@testable import PaymentsCore

class MockHTTPClient: HTTP {
    
    // MARK: - Properties
    private var defaultSendStub: HTTPResponse?
    
    private var sendStubs: [URLRequest: HTTPResponse] = [:]
    private var pendingCallbacks: [URLRequest: ((HTTPResponse) -> Void)] = [:]
    
    private(set) var lastSentRequest: URLRequest?
    
    // MARK: - HTTP
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPResponse) -> Void) {
        lastSentRequest = urlRequest
        if let stub = sendStubs[urlRequest] ?? defaultSendStub {
            completion(stub)
        } else {
            pendingCallbacks[urlRequest] = completion
        }
    }
    
    // MARK: - MockHTTPClient
    func stubSend(with httpResponse: HTTPResponse) {
        defaultSendStub = httpResponse
    }
    
    func stubSend(_ urlRequest: URLRequest, with httpResponse: HTTPResponse) {
        if let completion = pendingCallbacks[urlRequest] {
            completion(httpResponse)
        } else {
            sendStubs[urlRequest] = httpResponse
        }
    }
}
