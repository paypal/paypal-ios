@testable import CorePayments
@testable import CardPayments

class MockCardVaultDelegate: CardVaultDelegate {
    
    private var success: ((CardClient, CardVaultResult) -> Void)?
    private var failure: ((CardClient, CoreSDKError) -> Void)?
    private var cancel: ((CardClient) -> Void)?
    private var threeDSWillLaunch: ((CardClient) -> Void)?
    private var threeDSLaunched: ((CardClient) -> Void)?

    required init(
        success: ((CardClient, CardVaultResult) -> Void)? = nil,
        error: ((CardClient, CoreSDKError) -> Void)? = nil,
        cancel: ((CardClient) -> Void)? = nil,
        threeDSWillLaunch: ((CardClient) -> Void)? = nil,
        threeDSLaunched: ((CardClient) -> Void)? = nil
    ) {
        self.success = success
        self.failure = error
        self.cancel = cancel
        self.threeDSWillLaunch = threeDSWillLaunch
        self.threeDSLaunched = threeDSLaunched
    }

    func card(_ cardClient: CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        success?(cardClient, vaultResult)
    }

    func card(_ cardClient: CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        failure?(cardClient, vaultError)
    }

    func cardVaultDidCancel(_ cardClient: CardClient) {
        cancel?(cardClient)
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
        threeDSWillLaunch?(cardClient)
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
        threeDSLaunched?(cardClient)
    }
}
