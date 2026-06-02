import Foundation
@testable import CorePayments

class MockGetFundingEligibilityAPI: GetFundingEligibilityAPI {

    var stubEligibilityResponse: VenmoFundingEligibility?
    var stubError: Error?

    override func getFundingEligibility(
        intent: String,
        currency: String,
        enableFunding: [String]
    ) async throws -> VenmoFundingEligibility {

        if let stubError {
            throw stubError
        }

        if let stubEligibilityResponse {
            return stubEligibilityResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
