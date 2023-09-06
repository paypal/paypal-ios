@testable import CorePayments
@testable import CardPayments

class MockCardDelegate: CardDelegate {

    private var success: ((CardClient, CardResult) -> Void)?
    private var failure: ((CardClient, CoreSDKError) -> Void)?
    private var cancel: ((CardClient) -> Void)?
    private var threeDSWillLaunch: ((CardClient) -> Void)?
    private var threeDSLaunched: ((CardClient) -> Void)?

    required init(
        success: ((CardClient, CardResult) -> Void)? = nil,
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

    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
        success?(cardClient, result)
    }

    func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError) {
        failure?(cardClient, error)
    }

    func cardDidCancel(_ cardClient: CardClient) {
        cancel?(cardClient)
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
        threeDSWillLaunch?(cardClient)
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
        threeDSLaunched?(cardClient)
    }
}
