import Foundation

enum PaymentSourceType {
    case card
    case paypal(usageType: String)
}

struct SetUpTokenRequest {
    
    let customerID: String?
    let paymentSource: PaymentSourceType

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
        var paymentSourceDict: [String: Any] = [:]

        switch paymentSource {
        case .card:
            paymentSourceDict["card"] = [:]
        case .paypal(let usageType):
            paymentSourceDict["paypal"] = ["usage_type": usageType]
            paymentSourceDict["experience_context"] = ["return_url": "https://example.com/returnUrl", "cance_url": "https://example.com/cancelUrl"]
        }

        let requestBody: [String: Any] = [
            "customer": ["id": customerID],
            "payment_source": paymentSourceDict
        ]

        return try? JSONSerialization.data(withJSONObject: requestBody)
    }
}
