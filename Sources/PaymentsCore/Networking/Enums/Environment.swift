import Foundation

public enum Environment {
    case sandbox
    case staging
    case production

    // swiftlint:disable force_unwrapping
    public var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api.sandbox.paypal.com")!
        case .staging:
            return URL(string: "https://www.msmaster.qa.paypal.com")!
        case .production:
            return URL(string: "https://api.paypal.com")!
        }
    }
    // swiftlint:enable force_unwrapping
}
