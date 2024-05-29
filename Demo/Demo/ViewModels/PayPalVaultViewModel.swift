import UIKit
import PayPalWebPayments
import CorePayments

class PayPalVaultViewModel: VaultViewModel, PayPalVaultDelegate {

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    func vault(url: String, setupTokenID: String) async {
        guard let payPalURL = URL(string: url) else {
            return
        }
        DispatchQueue.main.async {
            self.state.paypalVaultTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let paypalClient = PayPalWebCheckoutClient(config: config)
            paypalClient.vaultDelegate = self
            let vaultRequest = PayPalVaultRequest(url: payPalURL, setupTokenID: setupTokenID)
            print("Attempt Vault")
            // swiftlint:disable line_length

            let venmoURL = """
            https://www.sandbox.paypal.com/checkoutnow?sessionID=\(UUID().uuidString)&buttonSessionID=\(UUID().uuidString)&stickinessID=\(UUID().uuidString)&sign_out_user=false&token=\(setupTokenID)&fundingSource=venmo&buyerCountry=US&locale.x=en_US&commit=true&client-metadata-id=\(UUID().uuidString)&enableFunding.0=venmo&clientID=\(config.clientID)&env=sandbox&xcomponent=1&version=1.3.0&pageURL=www.apple.com
            """
            
                        
            let venmoActualURL = URL(string: venmoURL)!
            Task {
                let success = await UIApplication.shared.open(venmoActualURL)
                if success {
                    print("opened")
                } else {
                    print("nah")
                }
            }
//            paypalClient.vault(vaultRequest)
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
