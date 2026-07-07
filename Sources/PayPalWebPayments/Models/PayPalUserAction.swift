import Foundation

/// Buyer action intent for checkout or vault.
///
/// Use `.setupNow` with `PayPalVaultRequest` only. Passing `.setupNow` to checkout (`start()`)
/// will return `PayPalError.invalidUserActionError`.
public enum PayPalUserAction {
    case `continue`
    case payNow
    case setupNow
}
