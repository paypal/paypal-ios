import Foundation

/// Buyer action intent for checkout or vault.
///
/// Use `.setupNow` with `PayPalVaultRequest` only. Passing `.setupNow` to checkout (`start()`)
/// will return `PayPalError.invalidUserActionError`.
public enum PayPalUserAction {
    case `continue`
    case payNow
    case setupNow
    
    public var title: String {
        switch self {
        case .continue:
            return "CONTINUE"
        case .payNow:
            return "PAY NOW"
        case .setupNow:
            return "SETUP NOW"
        }
    }
}
