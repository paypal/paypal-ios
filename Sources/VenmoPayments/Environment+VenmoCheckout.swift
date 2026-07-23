import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

    // swiftlint:disable force_unwrapping
    var venmoBaseURL: URL {
        switch self {
        case .sandbox:
            // Matches Android: the app-switch host is always the production Venmo host; the `env`
            // query parameter (sandbox/production) routes the Venmo app to the correct backend.
            return URL(string: "https://account.venmo.com")!
        case .live:
            return URL(string: "https://account.venmo.com")!
        case .custom:
            // QA end-to-end host confirmed with the Android team: qa.venmo.com.
            return URL(string: "https://qa.venmo.com")!
        }
    }
    // swiftlint:enable force_unwrapping
}
