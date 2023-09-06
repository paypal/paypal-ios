import Foundation
@testable import CardPayments
@testable import CorePayments

class MockVaultPaymentTokensAPI: VaultPaymentTokensAPI {
    
    var stubSetupTokenResponse: UpdateSetupTokenResponse?
    var stubError: Error?

    var capturedCardVaultRequest: CardVaultRequest?
    
    override func updateSetupToken(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse {
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
