import Foundation
import CorePayments

/// FPTI analytics events emitted by the `CardPayments` module.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum CardAnalyticsEvent {

    // MARK: - Approve Order

    public enum ApproveOrder: AnalyticsEventName {

        case started
        case authChallengeRequired
        case authChallengePresentationSucceeded
        case authChallengePresentationFailed
        case succeeded
        case failed
        case authChallengeSucceeded
        case authChallengeFailed
        case authChallengeCanceled

        public var eventName: String {
            switch self {
            case .started:
                return "card-payments:approve-order:started"
            case .authChallengeRequired:
                return "card-payments:approve-order:auth-challenge-required"
            case .authChallengePresentationSucceeded:
                return "card-payments:approve-order:auth-challenge-presentation:succeeded"
            case .authChallengePresentationFailed:
                return "card-payments:approve-order:auth-challenge-presentation:failed"
            case .succeeded:
                return "card-payments:approve-order:succeeded"
            case .failed:
                return "card-payments:approve-order:failed"
            case .authChallengeSucceeded:
                return "card-payments:approve-order:auth-challenge:succeeded"
            case .authChallengeFailed:
                return "card-payments:approve-order:auth-challenge:failed"
            case .authChallengeCanceled:
                return "card-payments:approve-order:auth-challenge:canceled"
            }
        }
    }

    // MARK: - Vault Without Purchase

    public enum Vault: AnalyticsEventName {

        case started
        case authChallengeRequired
        case authChallengePresentationSucceeded
        case authChallengePresentationFailed
        case succeeded
        case failed
        case authChallengeSucceeded
        case authChallengeFailed
        case authChallengeCanceled

        public var eventName: String {
            switch self {
            case .started:
                return "card-payments:vault-wo-purchase:started"
            case .authChallengeRequired:
                return "card-payments:vault-wo-purchase:auth-challenge-required"
            case .authChallengePresentationSucceeded:
                return "card-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
            case .authChallengePresentationFailed:
                return "card-payments:vault-wo-purchase:auth-challenge-presentation:failed"
            case .succeeded:
                return "card-payments:vault-wo-purchase:succeeded"
            case .failed:
                return "card-payments:vault-wo-purchase:failed"
            case .authChallengeSucceeded:
                return "card-payments:vault-wo-purchase:auth-challenge:succeeded"
            case .authChallengeFailed:
                return "card-payments:vault-wo-purchase:auth-challenge:failed"
            case .authChallengeCanceled:
                return "card-payments:vault-wo-purchase:auth-challenge:canceled"
            }
        }
    }
}
