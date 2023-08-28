import Foundation

struct PaymentTokenRequest {
    
    let setupToken: String
    
    var path: String {
        "/payment_tokens/"
    }

    var method: String {
        "POST"
    }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
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
