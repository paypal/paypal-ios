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

struct PaymentTokenParam: Encodable {

    let paymentSource: PaymentSource

    struct PaymentSource: Encodable {

        let token: Token

        public init(setupTokenID: String) {
            token = Token(id: setupTokenID)
        }
    }

    struct Token: Encodable {

        let id: String
        let type = "SETUP_TOKEN"
    }
}
