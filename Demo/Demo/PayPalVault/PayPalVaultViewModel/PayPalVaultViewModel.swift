import UIKit
import PayPalWebPayments
import CorePayments

class PayPalVaultViewModel: VaultViewModel {

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    func vault(setupTokenID: String) async {
        DispatchQueue.main.async {
            self.state.paypalVaultTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let paypalClient = PayPalWebCheckoutClient(config: config)
            let vaultRequest = PayPalVaultRequest(setupTokenID: setupTokenID)
            paypalClient.vault(vaultRequest) { result in
                switch result {
                case .success(let cardVaultResult):
                    DispatchQueue.main.async {
                        self.state.paypalVaultTokenResponse = .loaded(cardVaultResult)
                    }
                case .failure(let error):
                    if error == PayPalError.vaultCanceledError {
                        DispatchQueue.main.async {
                            print("Canceled")
                            self.state.paypalVaultTokenResponse = .idle
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.state.paypalVaultTokenResponse = .error(message: error.localizedDescription)
                        }
                    }
                }
            }
        } catch {
            print("Error in vaulting PayPal Payment")
            DispatchQueue.main.async {
                self.state.paypalVaultTokenResponse = .error(message: error.localizedDescription)
            }
        }
    }
}
