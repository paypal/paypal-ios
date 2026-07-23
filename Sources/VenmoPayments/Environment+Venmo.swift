import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

    // swiftlint:disable force_unwrapping

    /// The base URL for the Venmo checkout web flow.
    var venmoCheckoutBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/smart/checkout/venmo")!
        case .live:
            return URL(string: "https://www.paypal.com/smart/checkout/venmo")!
        case .custom:
            return URL(string: "https://www.sandbox.paypal.com/smart/checkout/venmo")!
        }
    }

    /// The environment string used in Venmo checkout URL query parameters.
    var venmoEnvironmentString: String {
        switch self {
        case .sandbox:
            return "sandbox"
        case .live:
            return "production"
        case .custom:
            // QA end-to-end: the Venmo app authenticates against stage/QA, so the paysheet request
            // must use `stage` (sandbox → UNAUTHORIZED under a stage session).
            return "stage"
        }
    }

    // swiftlint:enable force_unwrapping
}
