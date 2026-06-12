import Foundation
@testable import CorePayments

class MockPatchCCOAPI: PatchCCOAPIProtocol {

    var stubEligibilityResponse: AppSwitchEligibility?
    var stubError: Error?
    var capturedPaypalNativeAppInstalled: Bool?

    func patchCCOWithAppSwitchEligibility(
        token: String,
        tokenType: String,
        paypalNativeAppInstalled: Bool
    ) async throws -> AppSwitchEligibility {
        capturedPaypalNativeAppInstalled = paypalNativeAppInstalled

        if let stubError {
            throw stubError
        }

        if let stubEligibilityResponse {
            return stubEligibilityResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
