import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Protocol defining the interface for updating vault setup tokens.
protocol VaultedTokenSaving {

    func updateSetupToken(cardVaultRequest: CardVaultRequest) async throws -> UpdateSetupTokenResponse
}
