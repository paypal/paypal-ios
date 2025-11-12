import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

    // swiftlint:disable force_unwrapping
    var payPalBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://www.paypal.com")!
        case .custom(let baseURL):
            return URL(string: baseURL)!
        }
    }
    // swiftlint:enable force_unwrapping
}
