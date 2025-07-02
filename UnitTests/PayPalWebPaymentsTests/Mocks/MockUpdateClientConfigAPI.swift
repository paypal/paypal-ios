import Foundation
@testable import PayPalWebPayments
@testable import CorePayments

class MockClientConfigAPI: UpdateClientConfigAPI {

    var stubUpdateClientConfigResponse: ClientConfigResponse?
    var stubError: Error?

    var paypalWebRequest: PayPalWebCheckoutRequest?

    override func updateClientConfig(request: PayPalWebCheckoutRequest) async throws -> ClientConfigResponse {

        if let stubError {
            throw stubError
        }

        if let stubUpdateClientConfigResponse {
            return stubUpdateClientConfigResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
