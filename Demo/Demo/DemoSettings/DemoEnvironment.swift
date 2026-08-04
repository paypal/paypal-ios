import CorePayments

enum DemoEnvironment: String, CaseIterable {
    case sandbox
    case live
    #if DEBUG
    case custom
    #endif

    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://ppcp-mobile-demo-sandbox-87bbd7f0a27f.herokuapp.com"
        case .live:
            // we can replace during testing
            return "https://sdk-sample-merchant-server.herokuapp.com"
        #if DEBUG
        case .custom:
            // The custom REST/GraphQL/clientID fields configure the CorePayments SDK only
            // (see `paypalSDKEnvironment`). The merchant endpoints /orders, /setup-tokens and
            // /payment-tokens are served by the sample merchant backend, not the PayPal API.
            // A custom merchant URL can be provided; when empty it falls back to the sandbox
            // merchant server.
            let merchantBaseURL = DemoSettings.customEnvironment?.merchantBaseURL?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return merchantBaseURL.isEmpty ? DemoEnvironment.sandbox.baseURL : merchantBaseURL
        #endif
        }
    }

    var paypalSDKEnvironment: CorePayments.CoreEnvironment {
        switch self {
        case .sandbox:
            return .sandbox
        case .live:
            return .live
        #if DEBUG
        case .custom:
            let config = DemoSettings.customEnvironment
            return .custom(
                baseURL: config?.restBaseURL ?? "",
                graphQLURL: config?.graphQLBaseURL ?? ""
            )
        #endif
        }
    }
}
