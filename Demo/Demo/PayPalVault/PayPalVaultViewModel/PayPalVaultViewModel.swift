import UIKit
import PayPalWebPayments
import CorePayments

@MainActor
class PayPalVaultViewModel: VaultViewModel {

    let configManager = CoreConfigManager(domain: "PayPal Vault")

    var paypalClient: PayPalWebCheckoutClient?

    func vault() async throws {
        state.setupTokenResponse = .loading

        guard let client = try await getPayPalClient() else {
            let message = "Error initializing PayPalWebCheckoutClient"
            state.setupTokenResponse = .error(message: message)
            throw VaultFlowError.clientInitializationFailed(message)
        }
        paypalClient = client
        
        let resolvedUserIdentity = UserIdentityFactory.makeUserIdentity(
            selection: selectedUserIdentity,
            email: userEmail,
            phone: userPhone,
            ssid: userSSID
        )
        client.createPayPalSession(
            userIdentity: resolvedUserIdentity,
            urlConfig: shopperSessionURLConfig,
            userAction: selectedUserAction
        )

        async let setupTokenTask = fetchSetupToken(
            customerID: customerID.isEmpty ? nil : customerID,
            selectedMerchantIntegration: DemoSettings.merchantIntegration,
            paymentType: .paypal
        )
        let setupToken = try await setupTokenTask

        state.paypalVaultTokenResponse = .loading

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.vault(setupTokenID: setupToken.id) { result in
                switch result {
                case .success(let vaultResult):
                    self.state.paypalVaultTokenResponse = .loaded(vaultResult)
                    print("✅ Vault result: \(String(describing: vaultResult))")
                    continuation.resume()
                case .failure(let error):
                    if error == PayPalError.vaultCanceledError {
                        print("Canceled")
                        self.state.paypalVaultTokenResponse = .idle
                        continuation.resume()
                    } else {
                        self.state.paypalVaultTokenResponse = .error(message: error.localizedDescription)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    private var shopperSessionURLConfig: PayPalURLConfig {
        let checkoutPath = "x-callback-url/paypal-sdk/paypal-checkout"
        let scheme = PayPalCoreConstants.callbackURLScheme
        return PayPalURLConfig(
            returnAppUrl: "\(scheme)://\(checkoutPath)",
            cancelAppUrl: "\(scheme)://\(checkoutPath)/cancel",
            fallbackSchemeUrl: "\(scheme)://\(checkoutPath)"
        )
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient? {
        do {
            let config = try await configManager.getCoreConfig()
            return PayPalWebCheckoutClient(config: config)
        } catch {
            state.setupTokenResponse = .error(message: error.localizedDescription)
            print("❌ failed to create PayPalWebCheckoutClient with error: \(error.localizedDescription)")
            return nil
        }
    }

    func handleUniversalLinkReturn(_ url: URL) {
        guard let paypalClient else { return }
        paypalClient.handleReturnURL(url)
    }
}

private enum VaultFlowError: LocalizedError {
    case clientInitializationFailed(String)

    var errorDescription: String? {
        switch self {
        case .clientInitializationFailed(let message):
            return message
        }
    }
}
