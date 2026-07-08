enum PayPalWebAnalytics {

    static let apiRequestLatency = "paypal-web-payments:api-request-latency"
    static let systemLatency = "paypal-web-payments:system-latency"

    static let createOrderEndpoint = "/v2/checkout/orders"
    static let createSessionEndpoint = "/v2/vault/setup-tokens"

    enum Flow {
        static let checkout = "checkout"
        static let vault = "vault"
    }

    enum PresentationType {
        static let appSwitch = "app-switch"
        static let browser = "browser"
        static let error = "error"
    }
}

struct PendingSystemLatency {
    let startTime: Int64
    let flow: String
}
