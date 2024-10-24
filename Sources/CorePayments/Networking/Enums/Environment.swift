import Foundation

// swiftlint:disable force_unwrapping
public enum Environment {
    case sandbox
    case live

    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api-m.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://api-m.paypal.com")!
        }
    }

    public var graphQLURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/graphql")!
        case .live:
            return URL(string: "https://www.paypal.com/graphql")!
        }
    }
    
    /// URL used to display the PayPal Vault w/o Purchase experience in web browser
    public var paypalVaultCheckoutURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://sandbox.paypal.com/agreements/approve")!
        case .live:
            return URL(string: "https://paypal.com/agreements/approve")!
        }
    }
    
    public var toString: String {
        switch self {
        case .sandbox:
            return "sandbox"
        case .live:
            return "live"
        }
    }
}
// swiftlint:enable force_unwrapping
