
import UIKit
@testable import PaymentsCore

class APIClientMock: API {
    
    private(set) var lastSentRequest: APIRequest?
    
    private var sendStub: HTTPResponse?
    private var pendingCallback: ((HTTPResponse) -> Void)?
    
    func send(_ apiRequest: APIRequest, completion: @escaping (HTTPResponse) -> Void) {
        lastSentRequest = apiRequest
        if let stub = sendStub {
            completion(stub)
        } else {
            pendingCallback = completion
        }
    }
    
    func stubSend(with httpResponse: HTTPResponse) {
        if let completion = pendingCallback {
            completion(httpResponse)
        } else {
            sendStub = httpResponse
        }
    }
}
