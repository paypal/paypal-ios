import Foundation
import CorePayments

struct SetUpTokenRequest {
    
    typealias ResponseType = SetUpTokenResponse
    
    let customerID: String?
    
    var path: String {
        return "/setup_tokens/"
    }
    
    var method: CorePayments.HTTPMethod {
        return .post
    }
    
    var headers: [CorePayments.HTTPHeader: String] {
        return [.contentType: "application/json"]
    }
    
    var body: Data? {
        let requestBody: [String: Any] = [
            "customer": [
                "id": customerID
            ],
            "payment_source": [
                "card": [:],
                "experience_context": [
                    "returnUrl": "https://example.com/returnUrl",
                    "cancelUrl": "https://example.com/returnUrl"
                ]
            ]
        ]
        return try? JSONSerialization.data(withJSONObject: requestBody)
    }
}
