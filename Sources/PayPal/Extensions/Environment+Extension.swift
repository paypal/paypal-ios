#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
@_implementationOnly import PayPalCheckout
#endif

extension PaymentsCore.Environment {

    /// Convert `PaymentsCore.Environment` to `PayPalCheckout.Environment`
    func toPayPalCheckoutEnvironment() -> PayPalCheckout.Environment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .live
        }
    }
}
