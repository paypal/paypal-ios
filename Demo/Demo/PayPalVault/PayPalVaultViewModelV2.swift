import UIKit
import PayPalPayments
import FraudProtection
import CorePayments

@MainActor
@Observable
class PayPalVaultViewModelV2 {
    
    // MARK: Private Properties
    private let api = DemoMerchantAPI.shared
    
    private let payPalClient: PayPalClient
    private let payPalDataCollector: PayPalDataCollector

    // MARK: Observable Properties
    var createSetupTokenState: AsyncState<CreateSetupTokenResponse> = .idle
    var updateSetupTokenState: AsyncState<PayPalVaultResult> = .idle

    // MARK: Initializers
    init() {
        let configManager = CoreConfigManager(domain: "PayPal Vault")
        let config = configManager.getCoreConfig()

        payPalClient = PayPalClient(config: config)
        payPalDataCollector = PayPalDataCollector(config: config)
    }

    // MARK: Methods
    func createSetupToken(using request: DemoCreateCardSetupTokenRequest) {
        createSetupTokenState = .loading
        Task {
            do {
                let response = try await api.createPayPalSetupToken(using: request)
                createSetupTokenState = .loaded(response)
            } catch {
                createSetupTokenState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func updateSetupToken(using request: DemoUpdatePayPalSetupTokenRequest) {
        guard let setupTokenID = createSetupTokenState.value?.id else {
            updateSetupTokenState = .error(message: "Setup Token Required.")
            return
        }
        
        updateSetupTokenState = .loading
        Task {
            do {
                try initiatePayPalSession(using: request)
                let result = try await startPayPalVault(withSetupTokenID: setupTokenID)
                updateSetupTokenState = .loaded(result)
            } catch {
                if error as? CoreSDKError == PayPalError.checkoutCanceledError {
                    updateSetupTokenState = .error(message: "PayPal checkout was canceled.")
                } else {
                    updateSetupTokenState = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func startPayPalVault(withSetupTokenID setupTokenID: String) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalVaultResult, Error>) in
            payPalClient.vault(setupTokenID: setupTokenID) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func initiatePayPalSession(using request: DemoUpdatePayPalSetupTokenRequest) throws {
        let urlConfig: PayPalURLConfig
        do {
            urlConfig = try ShopperSessionURLConfigFactory.makeURLConfig()
        } catch {
            throw error
        }
        let userIdentity = UserIdentityFactory.makeUserIdentity(
            selection: request.userIdentity,
            email: request.email,
            phone: request.phone,
            ssid: request.ssid
        )
        payPalClient.createPayPalSession(
            sessionType: .checkout,
            userIdentity: userIdentity,
            urlConfig: urlConfig,
            userAction: request.userAction
        )
    }
}
