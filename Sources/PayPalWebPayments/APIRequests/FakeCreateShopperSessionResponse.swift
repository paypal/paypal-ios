import Foundation

enum FakeCreateShopperSessionSuccessResponse {

    static let success = ShopperSessionResult(
        appSwitchEligible: true,
        redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?appSwitchEligible=true&token=test-order-id&tokenType=ORDER_ID",
        checkoutFallbackUrl: "https://www.sandbox.paypal.com/checkoutnow",
        ineligibleReason: nil,
        matchedAuthenticationMethods: ["EMAIL"],
        shopperSessionConfig: .init(id: "fake-session-id", expiresAt: "2026-12-31T00:00:00Z")
    )
}
