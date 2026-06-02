import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

    // swiftlint:disable force_unwrapping
    var venmoBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://account.qa.venmo.com")!
        case .live:
            return URL(string: "https://account.venmo.com")!
        }
    }
    // swiftlint:enable force_unwrapping
}
