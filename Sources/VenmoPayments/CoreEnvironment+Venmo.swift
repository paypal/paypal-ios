import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension CoreEnvironment {

    /// The base URL used for the Venmo app-switch deep link.
    var venmoBaseURL: URL {
        switch self {
        case .sandbox:
            // Sandbox app-switch uses the ext.live Venmo host.
            return URL(string: "https://account.ext.live.venmo.com")!
        case .live:
            return URL(string: "https://account.venmo.com")!
        #if DEBUG
        case .custom:
            // iOS universal-link host: the Venmo iOS build is associated with account.qa.venmo.com
            // (the bare qa.venmo.com opens Safari).
            return URL(string: "https://account.qa.venmo.com")!
        #endif
        }
    }
}
