import Foundation

enum FakeCreateShopperSessionSuccessResponse {

    static let success = ShopperSessionResult(
        appSwitchEligible: true,
        redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout",
        checkoutFallbackUrl: "https://www.sandbox.paypal.com/checkoutnow",
        ineligibleReason: nil,
        matchedAuthenticationMethods: ["EMAIL"],
        shopperSessionConfig: .init(id: "fake-session-id", expiresAt: "2026-12-31T00:00:00Z")
    )
}
