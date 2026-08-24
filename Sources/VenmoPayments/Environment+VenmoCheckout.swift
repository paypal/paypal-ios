import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

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
