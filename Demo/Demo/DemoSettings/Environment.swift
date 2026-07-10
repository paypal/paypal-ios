import CorePayments

enum Environment: String, CaseIterable {
    case sandbox
    case live

    var baseURL: String {
        switch self {
        case .sandbox:
            // ⚠️ LOCAL QA TESTING — DO NOT COMMIT. Local sample merchant server.
            // Use 127.0.0.1 (not "localhost"): the server binds IPv4 only, but "localhost"
            // resolves to IPv6 ::1 first → connection refused. Simulator shares the Mac loopback.
            // Original: https://ppcp-mobile-demo-sandbox-87bbd7f0a27f.herokuapp.com
            return "http://127.0.0.1:8080"
        case .live:
            // we can replace during testing
            return "https://sdk-sample-merchant-server.herokuapp.com"
        }
    }

    var paypalSDKEnvironment: CorePayments.Environment {
        switch self {
        case .sandbox:
            // ⚠️ LOCAL QA TESTING — DO NOT COMMIT. Points the SDK at msmaster via Steven's .custom case.
            // Original: return .sandbox
            return .custom(baseURL: "https://msmaster.qa.paypal.com")
        case .live:
            return .live
        }
    }
}
