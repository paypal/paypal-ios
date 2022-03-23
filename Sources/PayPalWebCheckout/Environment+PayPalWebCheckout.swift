import Foundation

#if canImport(PaymentsCore)
import PaymentsCore
#endif

extension Environment {
    
    // swiftlint:disable force_unwrapping
    var payPalBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com")!
        case .production:
            return URL(string: "https://www.paypal.com")!
        }
    }
    // swiftlint:enable force_unwrapping
}
