import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// FPTI analytics events emitted by the `PaymentButtons` module.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum PaymentButtonAnalyticsEvent: AnalyticsEventName {

    case initialized
    case tapped

    public var eventName: String {
        switch self {
        case .initialized:
            return "payment-button:initialized"
        case .tapped:
            return "payment-button:tapped"
        }
    }
}
