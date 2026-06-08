import Foundation
@testable import CorePayments

class MockPatchCCOAPI: PatchCCOWithAppSwitchEligibility {

    var stubEligibilityResponse: AppSwitchEligibility?
    var stubError: Error?

    override func patchCCOWithAppSwitchEligibility(
        token: String,
        tokenType: String
    ) async throws -> AppSwitchEligibility {

        if let stubError {
            throw stubError
        }

        if let stubEligibilityResponse {
            return stubEligibilityResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
