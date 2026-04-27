import Foundation

/// A type-safe identifier for a PayPal SDK analytics event.
///
/// Each SDK module defines its own enum that conforms to this protocol
/// (for example, `CardAnalyticsEvent`, `PayPalWebAnalyticsEvent`,
/// `PaymentButtonAnalyticsEvent`). The `eventName` is the string that is
/// actually reported to FPTI.
///
/// This is exposed for internal PayPal use only. It is not covered by
/// Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public protocol AnalyticsEventName {

    /// The FPTI event name reported for this event.
    var eventName: String { get }
}
