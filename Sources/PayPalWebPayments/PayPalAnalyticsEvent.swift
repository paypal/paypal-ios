import Foundation

enum PayPalAnalyticsEvent {
    case checkoutStarted
    case checkoutSucceeded
    case checkoutFailed(errorDescription: String?)
    case checkoutCanceled
    case sessionCreated
    case sessionNotStarted
    case sessionCreationFailed
    case handleReturnStarted
    case handleReturnSucceeded
    case handleReturnFailed
    case appSwitchCanceled
    case appSwitchStarted
    case appSwitchSucceeded
    case browserLoginCanceled(errorDescription: String?)
    case browserLoginAlertCanceled(errorDescription: String?)
    case appSwitchFailed(eventPrefix: String, errorDescription: String)
    case authChallengePresentationStarted
    case authChallengePresentationFailed(errorDescription: String?)
    case authChallengePresentationSucceeded
    case fallbackToWeb(eventPrefix: String, reason: String)

    var canonicalName: String {
        switch self {
        case .checkoutStarted:
            return "paypal-web-payments:checkout:started"
        case .sessionCreated:
            return "paypal-web-payments:create-paypal-session:succeeded"
        case .sessionCreationFailed:
            return "paypal-web-payments:create-paypal-session:failed"
        case .sessionNotStarted:
            return "paypal-web-payments:checkout:session-not-started"
        case .handleReturnStarted:
            return "paypal-web-payments:checkout:handle-return:started"
        case .handleReturnSucceeded:
            return "paypal-web-payments:checkout:handle-return:succeeded"
        case .handleReturnFailed:
            return "paypal-web-payments:checkout:handle-return:failed"
        case .appSwitchCanceled:
            return "paypal-web-payments:checkout:app-switch:canceled"
        case .fallbackToWeb(let eventPrefix, let reason):
            return "\(eventPrefix):fallback-to-web:\(reason)"
        case .authChallengePresentationSucceeded:
            return "paypal-web-payments:checkout:auth-challenge-presentation:succeeded"
        case .authChallengePresentationFailed(errorDescription):
            return "paypal-web-payments:checkout:auth-challenge-presentation:failed"
        default:
            // TODO: gather missing analytics strings
            return ""
        }
    }
    
    // TODO: consider removing
    var errorDescription: String? {
        switch self {
        case .sessionNotStarted:
            return PayPalError.sessionNotStartedError.errorDescription
        default:
            return nil
        }
    }
}
