import Foundation

public enum Environment {
    case sandbox
    case production

    // swiftlint:disable force_unwrapping
    public var baseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api.sandbox.paypal.com")!
        case .production:
            return URL(string: "https://api.paypal.com")!
        }
    }

    public var payPalBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://sandbox.paypal.com")!
        case .production:
            return URL(string: "https://paypal.com")!
        }
    }
    // swiftlint:enable force_unwrapping
}
