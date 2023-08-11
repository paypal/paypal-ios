@testable import CorePayments
@testable import CardPayments

class MockCardVaultDelegate: CardVaultDelegate {
    
    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        success?(cardClient, vaultResult)
    }
    
    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        failure?(cardClient, vaultError)
    }
    
    
    private var success: ((CardClient, CardVaultResult) -> Void)?
    private var failure: ((CardClient, CoreSDKError) -> Void)?
    
    required init(
        success: ((CardClient, CardVaultResult) -> Void)? = nil,
        error: ((CardClient, CoreSDKError) -> Void)? = nil
    ) {
        self.success = success
        self.failure = error
    }
}
