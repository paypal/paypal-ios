import Foundation
import CardPayments
import CorePayments

@MainActor
@Observable
class CardVaultViewModelV2 {
    
    let uiState = CardVaultUiState()

    var createSetupTokenRequest: DemoCreateSetupTokenRequest {
        get { uiState.createSetupTokenRequest }
        set { uiState.createSetupTokenRequest = newValue }
    }
}
