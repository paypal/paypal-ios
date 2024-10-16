import Foundation
import CardPayments
import CorePayments

class CardVaultViewModel: VaultViewModel {

    let configManager = CoreConfigManager(domain: "Card Vault")

    func vault(card: Card, setupToken: String) async {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let cardClient = CardClient(config: config)
            let cardVaultRequest = CardVaultRequest(card: card, setupTokenID: setupToken)
            let vaultResult = try await cardClient.vault(cardVaultRequest)
            setUpdateSetupTokenResult(vaultResult: vaultResult)
        } catch {
            self.state.updateSetupTokenResponse = .error(message: error.localizedDescription)
            print("failed in updating setup token. \(error.localizedDescription)")
        }
    }

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    func setUpdateSetupTokenResult(vaultResult: CardVaultResult? = nil, vaultError: CoreSDKError? = nil) {
        DispatchQueue.main.async {
            if let vaultResult {
                self.state.updateSetupTokenResponse = .loaded(
                    UpdateSetupTokenResult(
                        id: vaultResult.setupTokenID,
                        status: vaultResult.status,
                        didAttemptThreeDSecureAuthentication: vaultResult.didAttemptThreeDSecureAuthentication
                    )
                )
            } else if let vaultError {
                self.state.updateSetupTokenResponse = .error(message: vaultError.localizedDescription)
            }
        }
    }
}
