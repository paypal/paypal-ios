import Foundation

// swiftlint:disable force_unwrapping
public enum Environment {
    case sandbox
    case live
    case custom(baseURL: String)
    
    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api-m.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://api-m.paypal.com")!
        case .custom(let baseURL):
            return URL(string: baseURL)!
        }
    }

    public var graphQLURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/graphql")!
        case .live:
            return URL(string: "https://www.paypal.com/graphql")!
        case .custom(let baseURL):
            return URL(string: "/graphql", relativeTo: URL(string: baseURL))!
        }
    }
    
    /// URL used to display the PayPal Vault w/o Purchase experience in web browser
    public var paypalVaultCheckoutURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://sandbox.paypal.com/agreements/approve")!
        case .live:
            return URL(string: "https://paypal.com/agreements/approve")!
        case .custom(let baseURL):
            return URL(string: "/agreements/approve", relativeTo: URL(string: baseURL))!
        }
    }
    
    public var toString: String {
        switch self {
        case .sandbox:
            return "sandbox"
        case .live:
            return "live"
        case .custom(let baseURL):
            return "custom with baseURL: \(baseURL)"
        }
    }
}
// swiftlint:enable force_unwrapping
