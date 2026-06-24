import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

extension Environment {

    var payPalBaseURL: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://www.paypal.com")!
        }
    }
}
