import Foundation
@testable import PayPalWebPayments
@testable import CorePayments

class MockClientConfigAPI: UpdateClientConfigAPI {

    var stubSetupTokenResponse: ClientConfigResponse?
    var stubError: Error?

    var paypalWebRequest: PayPalWebCheckoutRequest?

    override func updateClientConfig(request: PayPalWebCheckoutRequest) async throws -> ClientConfigResponse {

        if let stubError {
            throw stubError
        }

        if let stubSetupTokenResponse {
            return stubSetupTokenResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
