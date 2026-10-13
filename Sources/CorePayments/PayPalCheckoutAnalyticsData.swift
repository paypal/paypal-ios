import Foundation

/// Plain data holder for the analytics fields gathered over the lifetime of a checkout/vault attempt.
///
/// This is a value type on purpose: it is mutated as the flow progresses (e.g. `url` is set to the launch URL and
/// later to the return URL), and every analytics event captures a copy of it at the moment the event is sent.
/// Events therefore always reflect the state at the time they occurred, no matter when they are delivered.
///
/// This lives in `CorePayments` (rather than `PayPalPayments`) so `AnalyticsService`/`AnalyticsEventData`
/// can reference it without creating a module dependency cycle, since `PayPalPayments` already depends on
/// `CorePayments`. `PayPalPayments` populates it via an initializer declared in its own module
/// (see `PayPalCheckoutAnalyticsData+Analytics.swift` under `Sources/PayPalPayments/Models`), since the types that
/// initializer needs (`PayPalUserIdentity`, `PayPalURLConfig`, `PayPalUserAction`) live there.
@_documentation(visibility: private)
public struct PayPalCheckoutAnalyticsData: Sendable {

    public var isCachedSession: Bool?

    public var shopperSessionID: String?
    public var shopperSessionExpiration: String?
    
    public var url: URL?
    public var appSwitchEligible: Bool?
    public var ineligibleReason: String?

    public var fallbackUrl: String?

    public var isVaultRequest: Bool?

    public var userAction: String?

    public var paypalNativeAppInstalled: Bool?
    public var returnAppURL: URL?
    public var cancelAppURL: URL?
    public var fallbackSchemeURL: URL?

    public init() {}
}
