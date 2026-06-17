import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

#if DEBUG

/// DEBUG-only stubs for SSID GraphQL. Remove this folder when APIs are ready.
public enum PayPalWebPaymentsManualTesting {

    /// Set to `false` when createShopperSession GraphQL is ready.
    public static var isEnabled = false

    public static var ssidRouting = true
    public static var appSwitchEligible = true
    public static var stubSessionId = "ssid_manual_test"

    static func stubShopperSession(for environment: Environment) -> ShopperSessionWithAppSwitchEligibility {
        let base = environment.payPalBaseURL.absoluteString
        let json = """
        {
          "sessionId": "\(stubSessionId)",
          "expiresAt": "2026-12-31T23:59:59Z",
          "checkoutUrls": {
            "appCheckout": "\(base)/app-switch-checkout",
            "webCheckoutWeb": "\(base)/web-checkout",
            "appApprovalUrl": "\(base)/app-approval",
            "webApprovalUrl": "\(base)/web-approval"
          },
          "paymentMethodConfig": {
            "ssidRouting": \(ssidRouting),
            "appSwitchEligible": \(appSwitchEligible)
          }
        }
        """
        return try! JSONDecoder().decode(
            ShopperSessionWithAppSwitchEligibility.self,
            from: Data(json.utf8)
        )
    }
}

#endif
