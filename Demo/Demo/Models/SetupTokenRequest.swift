import Foundation

struct SetUpTokenRequest {
    
    let customerID: String?
    
    var path: String {
        "/setup_tokens/"
    }

    var method: String {
        "POST"
    }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        let requestBody: [String: Any] = [
            "customer": [
                "id": customerID
            ],
            "payment_source": [
                "card": [:]
            ]
        ]

        return try? JSONSerialization.data(withJSONObject: requestBody)
    }
}
