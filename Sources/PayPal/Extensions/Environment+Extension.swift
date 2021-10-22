import PaymentsCore
import PayPalCheckout

// TODO: add documentation
extension PaymentsCore.Environment {
    func toPayPalCheckoutEnvironment() -> PayPalCheckout.Environment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .live
        }
    }
}
