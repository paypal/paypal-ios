import Foundation
@testable import CorePayments
@testable import PayPalWebPayments

class MockCreateShopperSessionAPI: CreateShopperSessionAPI {

    var stubResponse: ShopperSessionResult?
    var stubError: Error?

    // Captured call arguments for assertion
    var capturedContextId: String?
    var capturedToken: String?
    var capturedTokenType: String?
    var capturedURLConfig: PayPalURLConfig?
    var capturedUserIdentity: PayPalUserIdentity?
    var callCount = 0

    override func createShopperSessionWithAppSwitchEligibility(
        contextId: String,
        token: String,
        tokenType: String,
        urlConfig: PayPalURLConfig,
        userIdentity: PayPalUserIdentity?
    ) async throws -> ShopperSessionResult {
        callCount += 1
        capturedContextId = contextId
        capturedToken = token
        capturedTokenType = tokenType
        capturedURLConfig = urlConfig
        capturedUserIdentity = userIdentity

        if let stubError {
            throw stubError
        }

        if let stubResponse {
            return stubResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
