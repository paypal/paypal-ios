@testable import CorePayments
@testable import CardPayments

class MockCardVaultDelegate: CardVaultDelegate {

    private var success: ((CardClient, CardVaultResult) -> Void)?
    private var failure: ((CardClient, CoreSDKError) -> Void)?
    
    required init(
        success: ((CardClient, CardVaultResult) -> Void)? = nil,
        error: ((CardClient, CoreSDKError) -> Void)? = nil
    ) {
        self.success = success
        self.failure = error
    }

    func card(_ cardClient: CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        success?(cardClient, vaultResult)
    }

    func card(_ cardClient: CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        failure?(cardClient, vaultError)
    }
}
