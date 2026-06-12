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
