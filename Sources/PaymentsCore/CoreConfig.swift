import Foundation

/*
 The configuration object containing information required by every payment method.
 It is used to initialize all Client objects.
 */
public struct CoreConfig {
    let clientID: String
    let environment: Environment
}

public enum Environment {
    case sandbox
    case stage
    case production

    //swiftlint:disable force_unwrapping
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
    //swiftlint:enable force_unwrapping
}
