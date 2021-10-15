
import UIKit
@testable import PaymentsCore

class APIClientMock: API {
    
    private(set) var lastSentRequest: APIRequest2?
    
    private var sendStub: HttpResponse?
    private var pendingCallback: ((HttpResponse) -> Void)?
    
    func send(_ apiRequest: APIRequest2, completion: @escaping (HttpResponse) -> Void) {
        lastSentRequest = apiRequest
        if let stub = sendStub {
            completion(stub)
        } else {
            pendingCallback = completion
        }
    }
    
    func stubSend(with httpResponse: HttpResponse) {
        if let completion = pendingCallback {
            completion(httpResponse)
        } else {
            sendStub = httpResponse
        }
    }
}
