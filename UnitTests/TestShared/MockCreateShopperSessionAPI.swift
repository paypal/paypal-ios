import Foundation
@testable import CorePayments
@testable import PayPalWebPayments

class MockCreateShopperSessionAPI: CreateShopperSessionAPI {

    var stubResponse: ShopperSessionResult?
    var stubError: Error?

    // Captured call arguments for assertion
    var capturedURLConfig: PayPalURLConfig?
    var capturedUserIdentity: PayPalUserIdentity?
    var capturedUserAction: PayPalUserAction?
    var callCount = 0

    override func createShopperSessionWithAppSwitchEligibility(
        urlConfig: PayPalURLConfig,
        userIdentity: PayPalUserIdentity?,
        userAction: PayPalUserAction
    ) async throws -> ShopperSessionResult {
        callCount += 1
        capturedURLConfig = urlConfig
        capturedUserIdentity = userIdentity
        capturedUserAction = userAction

        if let stubError {
            throw stubError
        }

        if let stubResponse {
            return stubResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
