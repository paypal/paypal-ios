import UIKit
import PayPalWebPayments
import CorePayments

class PayPalVaultViewModel: VaultViewModel, PayPalVaultDelegate {

    @Published var paypalVaultToken: PayPalVaultResult?

    @Published var paypalVaultTokenResponse: LoadingState<PayPalVaultResult> = .idle {
        didSet {
            if case .loaded(let value) = paypalVaultTokenResponse {
                paypalVaultToken = value
            }
        }
    }

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    func vault(url: String) async {
        guard let paypalUrl = URL(string: url) else {
            return
        }
        DispatchQueue.main.async {
            self.paypalVaultTokenResponse = .loading
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

    override func resetState() {
        super.resetState()
        paypalVaultToken = nil
        paypalVaultTokenResponse = .idle
    }

    // MARK: - PayPalVault Delegate

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultResult paypalVaultResult: PayPalVaultResult
    ) {
        DispatchQueue.main.async {
            self.paypalVaultTokenResponse = .loaded(paypalVaultResult)
        }
    }

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultError vaultError: CorePayments.CoreSDKError
    ) {

        DispatchQueue.main.async {
            self.paypalVaultTokenResponse = .error(message: vaultError.localizedDescription)
        }
    }

    func paypalDidCancel(_ payPalWebClient: PayPalWebCheckoutClient) {
        print("PayPal Checkout Canceled")
    }
}
