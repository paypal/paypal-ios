import UIKit
import CardPayments
import CorePayments

class CardVaultViewModel: ObservableObject, CardVaultDelegate {

    @Published var state = CardVaultState()

    func getSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            let setupTokenResult = try await DemoMerchantAPI.sharedService.getSetupToken(
                customerID: customerID,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.setupTokenResponse = setupTokenResult
            }
        } catch {
            throw error
        }
    }

    func getPaymentToken(
        setupToken: String,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            let paymentTokenResult = try await DemoMerchantAPI.sharedService.getPaymentToken(
                setupToken: setupToken,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = paymentTokenResult
            }
        } catch {
            throw error
        }
    }

    func vault(
        config: CoreConfig,
        card: Card,
        setupToken: String
    ) async {
        Task {
            let cardClient = CardClient(config: config)
            cardClient.vaultDelegate = self

            let cardVaultRequest = CardVaultRequest(card: card, setupTokenID: setupToken)
            cardClient.vault(vaultRequest: cardVaultRequest)
        }
    }

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    func updateUpdateSetupTokenResult(vaultResult: CardPayments.CardVaultResult) {
        DispatchQueue.main.async {
            self.state.updateSetupToken = CardVaultState.UpdateSetupTokenResult(id: vaultResult.setupTokenID, status: vaultResult.status)
        }
    }

    // MARK: - CardVault Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        print("vaultResult: \(vaultResult)")
        updateUpdateSetupTokenResult(vaultResult: vaultResult)
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        print("error: \(vaultError.errorDescription ?? "")")
    }
}
