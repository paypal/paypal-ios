import Foundation
import CorePayments

/// FPTI analytics events emitted by the `CardPayments` module.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum CardAnalyticsEvent: AnalyticsEventName {

    // MARK: - Approve Order

    case approveOrderStarted
    case approveOrderAuthChallengeRequired
    case approveOrderAuthChallengePresentationSucceeded
    case approveOrderAuthChallengePresentationFailed
    case approveOrderSucceeded
    case approveOrderFailed
    case approveOrderAuthChallengeSucceeded
    case approveOrderAuthChallengeFailed
    case approveOrderAuthChallengeCanceled

    // MARK: - Vault Without Purchase

    case vaultStarted
    case vaultAuthChallengeRequired
    case vaultAuthChallengePresentationSucceeded
    case vaultAuthChallengePresentationFailed
    case vaultSucceeded
    case vaultFailed
    case vaultAuthChallengeSucceeded
    case vaultAuthChallengeFailed
    case vaultAuthChallengeCanceled

    public var eventName: String {
        switch self {
        case .approveOrderStarted:
            return "card-payments:approve-order:started"
        case .approveOrderAuthChallengeRequired:
            return "card-payments:approve-order:auth-challenge-required"
        case .approveOrderAuthChallengePresentationSucceeded:
            return "card-payments:approve-order:auth-challenge-presentation:succeeded"
        case .approveOrderAuthChallengePresentationFailed:
            return "card-payments:approve-order:auth-challenge-presentation:failed"
        case .approveOrderSucceeded:
            return "card-payments:approve-order:succeeded"
        case .approveOrderFailed:
            return "card-payments:approve-order:failed"
        case .approveOrderAuthChallengeSucceeded:
            return "card-payments:approve-order:auth-challenge:succeeded"
        case .approveOrderAuthChallengeFailed:
            return "card-payments:approve-order:auth-challenge:failed"
        case .approveOrderAuthChallengeCanceled:
            return "card-payments:approve-order:auth-challenge:canceled"
        case .vaultStarted:
            return "card-payments:vault-wo-purchase:started"
        case .vaultAuthChallengeRequired:
            return "card-payments:vault-wo-purchase:auth-challenge-required"
        case .vaultAuthChallengePresentationSucceeded:
            return "card-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
        case .vaultAuthChallengePresentationFailed:
            return "card-payments:vault-wo-purchase:auth-challenge-presentation:failed"
        case .vaultSucceeded:
            return "card-payments:vault-wo-purchase:succeeded"
        case .vaultFailed:
            return "card-payments:vault-wo-purchase:failed"
        case .vaultAuthChallengeSucceeded:
            return "card-payments:vault-wo-purchase:auth-challenge:succeeded"
        case .vaultAuthChallengeFailed:
            return "card-payments:vault-wo-purchase:auth-challenge:failed"
        case .vaultAuthChallengeCanceled:
            return "card-payments:vault-wo-purchase:auth-challenge:canceled"
        }
    }
}
