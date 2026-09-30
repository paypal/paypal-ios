import Foundation
import CardPayments
import CorePayments

@Observable
@MainActor
class CardVaultViewModel {
    
    // MARK: Private Properties
    private let api = DemoMerchantAPI.shared
    private let cardClient: CardClient
    
    // MARK: Observable Properties
    var createSetupTokenState: AsyncState<CreateSetupTokenResponse> = .idle
    var updateSetupTokenState: AsyncState<UpdateSetupTokenResult> = .idle
    var createPaymentTokenState: AsyncState<PaymentTokenResponse> = .idle

    // MARK: Initializers
    init() {
        let configManager = CoreConfigManager(domain: "Card Payments")
        let config = configManager.getCoreConfig()
        cardClient = CardClient(config: config)
    }
    
    // MARK: Methods
    func createSetupToken(with request: DemoCreateCardSetupTokenRequest) {
        createSetupTokenState = .loading
        Task {
            do {
                let experienceContext = VaultExperienceContext()
                let verification = request.sca.rawValue
                let paymentSource: PaymentSourceType =
                    .card(verification: verification, experienceContext: experienceContext)
                let response = try await api.createSetupToken(
                    customerID: request.customerID,
                    integration: DemoSettings.merchantIntegration,
                    paymentSource: paymentSource
                )
                createSetupTokenState = .loaded(response)
            } catch {
                createSetupTokenState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func updateSetupToken(with card: Card) {
        if let setupTokenResult = createSetupTokenState.value {
            updateSetupTokenState = .loading
            Task {
                let setupTokenID = setupTokenResult.id
                let vaultRequest = CardVaultRequest(card: card, setupTokenID: setupTokenID)
                cardClient.vault(vaultRequest) { vaultResult in
                    Task { @MainActor [weak self] in
                        self?.captureVaultResult(vaultResult)
                    }
                }
            }
        } else {
           updateSetupTokenState = .error(message: "Setup Token Required.")
        }
    }
    
    private func captureVaultResult(_ vaultResult: Result<CardVaultResult, CoreSDKError>) {
        switch vaultResult {
        case .success(let vaultResult):
            let didAttemptThreeDSecureAuthentication =
                vaultResult.didAttemptThreeDSecureAuthentication
            updateSetupTokenState = .loaded(
                // TODO: determine if this type is actually needed; we should be able to forward
                // the SDK type instead here
                UpdateSetupTokenResult(
                    id: vaultResult.setupTokenID,
                    status: vaultResult.status,
                    didAttemptThreeDSecureAuthentication: didAttemptThreeDSecureAuthentication
                )
            )
        case .failure(let error):
            if error == CardError.threeDSecureCanceledError {
                print("Canceled")
                updateSetupTokenState = .idle
            } else {
                let errorMessage = error.localizedDescription
                updateSetupTokenState = .error(message: errorMessage)
            }
        }
    }
    
    func createPaymentToken() {
        if let setupTokenResult = createSetupTokenState.value {
            createPaymentTokenState = .loading
            Task {
                let setupTokenID = setupTokenResult.id
                do {
                    let paymentTokenResult = try await api.createPaymentToken(
                        setupToken: setupTokenID,
                        integration: DemoSettings.merchantIntegration
                    )
                    createPaymentTokenState = .loaded(paymentTokenResult)
                } catch {
                    createPaymentTokenState = .error(message: error.localizedDescription)
                }
            }
        } else {
            createPaymentTokenState = .error(message: "Setup Token Required.")
        }
    }
}
