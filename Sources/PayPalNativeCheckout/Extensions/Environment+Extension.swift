@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if COCOAPODS
private typealias PayPalEnvironment = PayPal.Environment
#else
private typealias PayPalEnvironment = PaymentsCore.Environment
#endif

extension PayPalEnvironment {
    
    func toNativeCheckoutSDKEnvironment() -> PayPalCheckout.Environment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .live
        }
    }
}
