import Foundation
@testable import CorePayments

class MockClientConfigUpdatingAPI: ClientConfigUpdating {

    var stubUpdateClientConfigResponse: ClientConfigResponse?
    var stubError: Error?
    private(set) var updateClientConfigCallCount = 0
    var capturedToken: String?
    var capturedFundingSource: String?

    func updateClientConfig(token: String, fundingSource: String) async throws -> ClientConfigResponse {
        updateClientConfigCallCount += 1
        capturedToken = token
        capturedFundingSource = fundingSource

        if let stubError {
            throw stubError
        }

        if let stubUpdateClientConfigResponse {
            return stubUpdateClientConfigResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
