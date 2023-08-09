import Foundation
import CorePayments

struct PaymentTokenRequest {
    
	let setupToken: String
    
    var path: String {
        return "/payment_tokens/"
    }
    
    var method: CorePayments.HTTPMethod {
        return .post
    }
    
    var headers: [CorePayments.HTTPHeader: String] {
        return [.contentType: "application/json"]
    }
    
    var body: Data? {
        let requestBody: [String: Any] = [
            "payment_source": [
                "token": [
                    "id": setupToken,
                    "type": "SETUP_TOKEN"
                ]
            ]
        ]
        return try? JSONSerialization.data(withJSONObject: requestBody)
    }
}
