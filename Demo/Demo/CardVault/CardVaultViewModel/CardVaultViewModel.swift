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
            cardClient.vault(cardVaultRequest) { result in
                switch result {
                case .success(let cardVaultResult):
                    self.setUpdateSetupTokenResult(vaultResult: cardVaultResult, vaultError: nil)
                case .failure(let error):
                    self.setUpdateSetupTokenResult(vaultResult: nil, vaultError: error)
                }
            }
        } catch {
            self.setUpdateSetupTokenResult(vaultResult: nil, vaultError: error)
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

    func setUpdateSetupTokenResult(vaultResult: CardVaultResult? = nil, vaultError: Error? = nil) {
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
                if let error = vaultError as? CoreSDKError, error == CardError.threeDSecureCanceledError {
                    print("Canceled")
                    self.state.updateSetupTokenResponse = .idle
                } else {
                    self.state.updateSetupTokenResponse = .error(message: vaultError.localizedDescription)
                }
            }
        }
    }
}
