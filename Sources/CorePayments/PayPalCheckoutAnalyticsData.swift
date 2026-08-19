import Foundation

/// Plain data holder for the analytics fields gathered over the lifetime of a checkout/vault attempt.
/// This lives in `CorePayments` (rather than `PayPalPayments`) so `AnalyticsService`/`AnalyticsEventData`
/// can reference it without creating a module dependency cycle, since `PayPalPayments` already depends on
/// `CorePayments`. `PayPalPayments` populates it via a convenience initializer declared in its own module
/// (see `PayPalCheckoutAnalyticsData.swift` under `Sources/PayPalPayments/Models`), since the types that
/// initializer needs (`PayPalUserIdentity`, `PayPalURLConfig`, `PayPalUserAction`) live there.
@_documentation(visibility: private)
public final class PayPalCheckoutAnalyticsData {

    public var isCachedSession: Bool?

    public var shopperSessionID: String?
    public var shopperSessionExpiration: String?
    
    public var appSwitchURL: URL?
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
