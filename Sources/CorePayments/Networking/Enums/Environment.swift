import Foundation

// swiftlint:disable force_unwrapping
public enum Environment {
    case sandbox
    case live

    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://api.paypal.com")!
        }
    }

    public var graphQLURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/graphql")!
        case .live:
            return URL(string: "https://paypal.com/graphql")!
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
