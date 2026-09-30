import Foundation
import CardPayments
import CorePayments

@Observable
@MainActor
class CardVaultViewModel {

    private let cardClient: CardClient

    init() {
        let configManager = CoreConfigManager(domain: "Card Payments")
        let config = configManager.getCoreConfig()
        cardClient = CardClient(config: config)
    }
    
    func createSetupToken(with request: DemoCreateCardSetupTokenRequest) {
        
    }
}
