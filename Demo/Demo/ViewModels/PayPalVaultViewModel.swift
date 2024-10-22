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
            paypalClient.vault(vaultRequest) { result, error in
                if let error {
                    DispatchQueue.main.async {
                        self.state.paypalVaultTokenResponse = .error(message: error.localizedDescription)
                    }
                } else if let result {
                    DispatchQueue.main.async {
                        self.state.paypalVaultTokenResponse = .loaded(result)
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
