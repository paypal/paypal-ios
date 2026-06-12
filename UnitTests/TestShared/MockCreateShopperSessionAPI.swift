import Foundation
@testable import PayPalWebPayments

class MockCreateShopperSessionAPI: CreateShopperSessionAPIProtocol {

    var stubSession: ShopperSessionWithAppSwitchEligibility?
    var stubError: Error?
    var checkoutCallCount = 0
    var vaultCallCount = 0

    func createShopperSessionForCheckout(
        request: PayPalWebCheckoutRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility {
        checkoutCallCount += 1
        if let stubError { throw stubError }
        if let stubSession { return stubSession }
        throw NSError(domain: "MockCreateShopperSessionAPI", code: 0)
    }

    func createShopperSessionForVault(
        request: PayPalVaultRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility {
        vaultCallCount += 1
        if let stubError { throw stubError }
        if let stubSession { return stubSession }
        throw NSError(domain: "MockCreateShopperSessionAPI", code: 0)
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
