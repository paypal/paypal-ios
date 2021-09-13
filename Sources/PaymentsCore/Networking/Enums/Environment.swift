import Foundation

public enum Environment {
    case sandbox
    case stage
    case production

    var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api.sandbox.paypal.com")!
        case .stage:
            return URL(string: "https://api.msmaster.qa.paypal.com")!
        case .production:
            return URL(string: "https://api.paypal.com")!
        }
    }
}
