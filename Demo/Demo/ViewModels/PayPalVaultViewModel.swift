import UIKit
import PayPalWebPayments
import CorePayments

class PayPalVaultViewModel: VaultViewModel, PayPalVaultDelegate {

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    func vault(url: String) async {
        guard let paypalUrl = URL(string: url) else {
            return
        }
        DispatchQueue.main.async {
            self.state.paypalVaultTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let paypalClient = PayPalWebCheckoutClient(config: config)
            paypalClient.vaultDelegate = self
            paypalClient.vault(url: paypalUrl)
        } catch {
            print("Error in vaulting PayPal Payment")
        }
    }

    // MARK: - PayPalVault Delegate

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultResult paypalVaultResult: PayPalVaultResult
    ) {
        DispatchQueue.main.async {
            self.state.paypalVaultTokenResponse = .loaded(paypalVaultResult)
        }
    }

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultError vaultError: CorePayments.CoreSDKError
    ) {

        DispatchQueue.main.async {
            self.state.paypalVaultTokenResponse = .error(message: vaultError.localizedDescription)
        }
    }

    func paypalDidCancel(_ payPalWebClient: PayPalWebCheckoutClient) {
        print("PayPal Checkout Canceled")
    }
}
