import PayPalCheckout

#if canImport(CorePayments)
import CorePayments
#endif

#if COCOAPODS
private typealias PayPalEnvironment = PayPal.Environment
#else
private typealias PayPalEnvironment = CorePayments.Environment
#endif

extension PayPalEnvironment {

    func toNativeCheckoutSDKEnvironment() -> PayPalCheckout.Environment {
        switch self {
        case .sandbox:
            return .sandbox
        case .live:
            return .live
        }
    }
}
