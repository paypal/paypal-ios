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
