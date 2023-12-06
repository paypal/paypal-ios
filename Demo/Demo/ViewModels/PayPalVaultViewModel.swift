import UIKit
import PayPalWebPayments
import CorePayments

class PayPalVaultViewModel: VaultViewModel {

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    func vault(url: String) async {
        guard let paypalUrl = URL(string: url) else {
            return
        }
        do {
            let config = try await configManager.getCoreConfig()
            let paypalClient = PayPalWebCheckoutClient(config: config)
            paypalClient.vault(url: paypalUrl)
        } catch {
            print("Error in vaulting PayPal Payment")
        }
    }
}
