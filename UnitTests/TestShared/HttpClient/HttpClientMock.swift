
import UIKit
@testable import PaymentsCore

class HttpClientMock: Http {
    
    // MARK: - Properties
    private var defaultSendStub: HttpResponse?
    
    private var sendStubs: [URLRequest: HttpResponse] = [:]
    private var pendingCallbacks: [URLRequest: ((HttpResponse) -> Void)] = [:]
    
    private(set) var lastSentRequest: URLRequest?
    
    // MARK: - Http
    func send(_ urlRequest: URLRequest, completion: @escaping (HttpResponse) -> Void) {
        lastSentRequest = urlRequest
        if let stub = sendStubs[urlRequest] ?? defaultSendStub {
            completion(stub)
        } else {
            pendingCallbacks[urlRequest] = completion
        }
    }
    
    // MARK: - HttpClientMock
    func stubSend(with httpResponse: HttpResponse) {
        defaultSendStub = httpResponse
    }
    
    func stubSend(_ urlRequest: URLRequest, with httpResponse: HttpResponse) {
        if let completion = pendingCallbacks[urlRequest] {
            completion(httpResponse)
        } else {
            sendStubs[urlRequest] = httpResponse
        }
    }
}
