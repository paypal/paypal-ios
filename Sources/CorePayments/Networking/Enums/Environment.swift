import Foundation

public enum Environment: Equatable {
    case sandbox
    case live

    #if DEBUG
    case custom(baseURL: String, graphQLURL: String)
    #endif

    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api-m.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://api-m.paypal.com")!
        #if DEBUG
        case .custom(let baseURL, _):
            return URL(string: baseURL) ?? URL(fileURLWithPath: "")
        #endif
        }
    }

    public var graphQLURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/graphql")!
        case .live:
            return URL(string: "https://www.paypal.com/graphql")!
        #if DEBUG
        case .custom(_, let graphQLURL):
            return URL(string: graphQLURL) ?? URL(fileURLWithPath: "")
        #endif
        }
    }

    /// URL used to display the PayPal Vault w/o Purchase experience in web browser
    public var paypalVaultCheckoutURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://sandbox.paypal.com/agreements/approve")!
        case .live:
            return URL(string: "https://paypal.com/agreements/approve")!
        #if DEBUG
        case .custom:
            if let host = graphQLURL.host,
                let url = URL(string: "https://\(host)/agreements/approve") {
                return url
            }
            return URL(string: "https://paypal.com/agreements/approve")!
        #endif
        }
    }

    public var toString: String {
        switch self {
        case .sandbox:
            return "sandbox"
        case .live:
            return "live"
        #if DEBUG
        case .custom:
            return "custom"
        #endif
        }
    }
}