import Foundation
@testable import CardPayments
@testable import CorePayments

class MockVaultedTokenSavingAPI: VaultedTokenSaving {

    var stubSetupTokenResponse: UpdateSetupTokenResponse?
    var stubError: Error?
    private(set) var updateSetupTokenCallCount = 0
    var capturedCardVaultRequest: CardVaultRequest?

    func updateSetupToken(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse {
        updateSetupTokenCallCount += 1
        capturedCardVaultRequest = cardVaultRequest

        if let stubError {
            throw stubError
        }

        if let stubSetupTokenResponse {
            return stubSetupTokenResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
