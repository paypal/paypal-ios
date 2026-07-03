import CorePayments

enum Environment: String, CaseIterable {
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
            // The custom fields (REST/GraphQL/clientID) configure the CorePayments SDK only
            // (see `paypalSDKEnvironment`). The merchant endpoints /orders, /setup-tokens and
            // /payment-tokens are served by the sample merchant backend, not the PayPal API,
            // so they keep using the existing sandbox merchant server.
            return Environment.sandbox.baseURL
        #endif
        }
    }

    var paypalSDKEnvironment: CorePayments.Environment {
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
