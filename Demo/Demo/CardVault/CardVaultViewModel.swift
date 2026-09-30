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
}
