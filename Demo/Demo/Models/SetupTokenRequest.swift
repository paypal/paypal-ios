import Foundation
import CorePayments

struct SetUpTokenRequest {
    
    let customerID: String?
    
    var path: String {
        "/setup_tokens/"
    }
    
    var method: CorePayments.HTTPMethod {
        .post
    }
    
    var headers: [CorePayments.HTTPHeader: String] {
        [.contentType: "application/json"]
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
