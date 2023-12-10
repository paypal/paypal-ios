import UIKit
import CardPayments
import CorePayments

class CardVaultViewModel: VaultViewModel, CardVaultDelegate {

    struct UpdateSetupTokenResult: Decodable, Equatable {

        var id: String
        var status: String
    }

    @Published var updateSetupToken: UpdateSetupTokenResult?

    @Published var updateSetupTokenResponse: LoadingState<UpdateSetupTokenResult> = .idle {
        didSet {
            if case .loaded(let value) = updateSetupTokenResponse {
                updateSetupToken = value
            }
        }
    }

    let configManager = CoreConfigManager(domain: "Card Vault")

    func vault(card: Card, setupToken: String) async {
        DispatchQueue.main.async {
            self.updateSetupTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let cardClient = CardClient(config: config)
            cardClient.vaultDelegate = self
            let cardVaultRequest = CardVaultRequest(card: card, setupTokenID: setupToken)
            cardClient.vault(cardVaultRequest)
        } catch {
            updateSetupTokenResponse = .error(message: error.localizedDescription)
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

    func setUpTokenSuccessResult(vaultResult: CardPayments.CardVaultResult) {
        DispatchQueue.main.async {
            self.updateSetupTokenResponse = .loaded(
                UpdateSetupTokenResult(id: vaultResult.setupTokenID, status: vaultResult.status)
            )
        }
    }

    func setUpdateSetupTokenFailureResult(vaultError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.updateSetupTokenResponse = .error(message: vaultError.localizedDescription)
        }
    }

    override func resetState() {
        super.resetState()
        updateSetupToken = nil
        updateSetupTokenResponse = .idle
    }
    
    // MARK: - CardVault Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        print("vaultResult: \(vaultResult)")
        setUpTokenSuccessResult(vaultResult: vaultResult)
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        print("error: \(vaultError.errorDescription ?? "")")
        setUpdateSetupTokenFailureResult(vaultError: vaultError)
    }
}
