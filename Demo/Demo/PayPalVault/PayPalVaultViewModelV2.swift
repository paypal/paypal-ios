import UIKit
import PayPalPayments
import CorePayments

@MainActor
@Observable
class PayPalVaultViewModelV2 {
    
    // MARK: Private Properties
    private let api = DemoMerchantAPI.shared

    // MARK: Observable Properties
    var createSetupTokenState: AsyncState<CreateSetupTokenResponse> = .idle

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
        
    }
}
