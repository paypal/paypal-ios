import Foundation
@testable import PayPalWebPayments

extension PayPalURLConfig {

    static var testDefault: PayPalURLConfig {
        PayPalURLConfig(
            returnAppUrl: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout",
            cancelAppUrl: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?opType=cancel"
        )
    }
}

extension PayPalWebCheckoutRequest {

    static func testDefault(userAction: PayPalUserAction = .continue) -> PayPalWebCheckoutRequest {
        PayPalWebCheckoutRequest(urlConfig: .testDefault, userAction: userAction)
    }
}

extension PayPalVaultRequest {

    static func testDefault(userAction: PayPalUserAction = .setupNow) -> PayPalVaultRequest {
        PayPalVaultRequest(urlConfig: .testDefault, userAction: userAction)
    }
}

extension ShopperSessionWithAppSwitchEligibility {

    static func stub(
        sessionId: String = "ssid_test",
        ssidRouting: Bool = true,
        appSwitchEligible: Bool = true
    ) -> ShopperSessionWithAppSwitchEligibility {
        let json = """
        {
          "sessionId": "\(sessionId)",
          "expiresAt": "2026-06-11T02:00:00Z",
          "checkoutUrls": {
            "appCheckout": "https://www.sandbox.paypal.com/app-checkout",
            "webCheckoutWeb": "https://www.sandbox.paypal.com/web-checkout",
            "appApprovalUrl": "https://www.sandbox.paypal.com/app-approval",
            "webApprovalUrl": "https://www.sandbox.paypal.com/web-approval"
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
