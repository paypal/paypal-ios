import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension CoreEnvironment {

    /// The base URL for the Venmo checkout web flow.
    var venmoCheckoutBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com/smart/checkout/venmo")!
        case .live:
            return URL(string: "https://www.paypal.com/smart/checkout/venmo")!
        #if DEBUG
        case .custom:
            return URL(string: "https://www.sandbox.paypal.com/smart/checkout/venmo")!
        #endif
        }
    }

    /// The environment string used in Venmo checkout URL query parameters.
    var venmoEnvironmentString: String {
        switch self {
        case .sandbox:
            return "sandbox"
        case .live:
            return "production"
        #if DEBUG
        case .custom:
            // QA end-to-end: the Venmo app authenticates against stage/QA, so the paysheet request
            // must use `stage` (sandbox → UNAUTHORIZED under a stage session).
            return "stage"
        #endif
        }
    }

    /// The base URL used for the Venmo app-switch deep link.
    var venmoBaseURL: URL {
        switch self {
        case .sandbox:
            // Matches Android: the app-switch host is always the production Venmo host; the `env`
            // query parameter (sandbox/production) routes the Venmo app to the correct backend.
            return URL(string: "https://account.venmo.com")!
        case .live:
            return URL(string: "https://account.venmo.com")!
        #if DEBUG
        case .custom:
            // iOS universal-link host: the Venmo iOS build is associated with account.qa.venmo.com
            // (the bare qa.venmo.com opens Safari). Android uses qa.venmo.com via App Links.
            return URL(string: "https://account.qa.venmo.com")!
        #endif
        }
    }
}
