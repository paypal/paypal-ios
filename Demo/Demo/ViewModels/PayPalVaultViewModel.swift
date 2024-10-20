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
            let result = try await paypalClient.vault(vaultRequest)
            DispatchQueue.main.async {
                self.state.paypalVaultTokenResponse = .loaded(result)
            }
        } catch {
            print("Error in vaulting PayPal Payment")
        }
    }
}
