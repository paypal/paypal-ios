import Foundation
import CorePayments

/// FPTI analytics events emitted by the `PayPalWebPayments` module.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum PayPalWebAnalyticsEvent: AnalyticsEventName {

    // MARK: - Checkout

    case checkoutStarted
    case checkoutAuthChallengePresentationSucceeded
    case checkoutAuthChallengePresentationFailed
    case checkoutSucceeded
    case checkoutFailed
    case checkoutCanceled

    // MARK: - Vault Without Purchase

    case vaultStarted
    case vaultAuthChallengePresentationSucceeded
    case vaultAuthChallengePresentationFailed
    case vaultSucceeded
    case vaultFailed
    case vaultCanceled

    public var eventName: String {
        switch self {
        case .checkoutStarted:
            return "paypal-web-payments:checkout:started"
        case .checkoutAuthChallengePresentationSucceeded:
            return "paypal-web-payments:checkout:auth-challenge-presentation:succeeded"
        case .checkoutAuthChallengePresentationFailed:
            return "paypal-web-payments:checkout:auth-challenge-presentation:failed"
        case .checkoutSucceeded:
            return "paypal-web-payments:checkout:succeeded"
        case .checkoutFailed:
            return "paypal-web-payments:checkout:failed"
        case .checkoutCanceled:
            return "paypal-web-payments:checkout:canceled"
        case .vaultStarted:
            return "paypal-web-payments:vault-wo-purchase:started"
        case .vaultAuthChallengePresentationSucceeded:
            return "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
        case .vaultAuthChallengePresentationFailed:
            return "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed"
        case .vaultSucceeded:
            return "paypal-web-payments:vault-wo-purchase:succeeded"
        case .vaultFailed:
            return "paypal-web-payments:vault-wo-purchase:failed"
        case .vaultCanceled:
            return "paypal-web-payments:vault-wo-purchase:canceled"
        }
    }
}
