import Foundation
@testable import CorePayments

class MockClientConfigAPI: UpdateClientConfigAPI {

    var stubUpdateClientConfigResponse: ClientConfigResponse?
    var stubError: Error?
    var capturedFundingSource: String?

    override func updateClientConfig(token: String, fundingSource: String) async throws -> ClientConfigResponse {
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
