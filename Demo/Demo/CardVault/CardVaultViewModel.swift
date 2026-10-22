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
    var updateSetupTokenState: AsyncState<CardVaultResult> = .idle
    var createPaymentTokenState: AsyncState<PaymentTokenResponse> = .idle
    
    // this is used to track changes and drive the scroll-to-bottom animation
    var stateHash: Int {
        return hash(createSetupTokenState, updateSetupTokenState, createPaymentTokenState)
    }

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
                let response = try await api.createSetupToken(using: request)
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
            updateSetupTokenState = .loaded(vaultResult)
        case .failure(let error):
            if error == CardError.threeDSecureCanceledError {
                updateSetupTokenState = .idle
            } else {
                let errorMessage = error.localizedDescription
                updateSetupTokenState = .error(message: errorMessage)
            }
        }
    }
    
    func createPaymentToken() {
        guard let setupTokenID = createSetupTokenState.value?.id else {
            createPaymentTokenState = .error(message: "Setup Token Required.")
            return
        }
        
        createPaymentTokenState = .loading
        Task {
            do {
                let result = try await api.createPaymentToken(setupTokenID: setupTokenID)
                createPaymentTokenState = .loaded(result)
            } catch {
                createPaymentTokenState = .error(message: error.localizedDescription)
            }
        }
    }
}
