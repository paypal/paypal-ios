import Foundation
import CorePayments

/// FPTI analytics events emitted by the `PayPalWebPayments` module.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum PayPalWebAnalyticsEvent {

    // MARK: - Checkout

    public enum Checkout: AnalyticsEventName {

        case started
        case authChallengePresentationSucceeded
        case authChallengePresentationFailed
        case succeeded
        case failed
        case canceled

        public var eventName: String {
            switch self {
            case .started:
                return "paypal-web-payments:checkout:started"
            case .authChallengePresentationSucceeded:
                return "paypal-web-payments:checkout:auth-challenge-presentation:succeeded"
            case .authChallengePresentationFailed:
                return "paypal-web-payments:checkout:auth-challenge-presentation:failed"
            case .succeeded:
                return "paypal-web-payments:checkout:succeeded"
            case .failed:
                return "paypal-web-payments:checkout:failed"
            case .canceled:
                return "paypal-web-payments:checkout:canceled"
            }
        }
    }

    // MARK: - Vault Without Purchase

    public enum Vault: AnalyticsEventName {

        case started
        case authChallengePresentationSucceeded
        case authChallengePresentationFailed
        case succeeded
        case failed
        case canceled

        public var eventName: String {
            switch self {
            case .started:
                return "paypal-web-payments:vault-wo-purchase:started"
            case .authChallengePresentationSucceeded:
                return "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
            case .authChallengePresentationFailed:
                return "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed"
            case .succeeded:
                return "paypal-web-payments:vault-wo-purchase:succeeded"
            case .failed:
                return "paypal-web-payments:vault-wo-purchase:failed"
            case .canceled:
                return "paypal-web-payments:vault-wo-purchase:canceled"
            }
        }
    }
}
