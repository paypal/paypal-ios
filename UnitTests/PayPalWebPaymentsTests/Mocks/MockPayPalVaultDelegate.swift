@testable import CorePayments
@testable import PayPalWebPayments

class MockPayPalVaultDelegate: PayPalVaultDelegate {

    private var success: ((PayPalWebCheckoutClient, PayPalVaultResult) -> Void)?
    private var failure: ((PayPalWebCheckoutClient, CoreSDKError) -> Void)?
    private var cancel: ((PayPalWebCheckoutClient) -> Void)?

    required init(
        success: ((PayPalWebCheckoutClient, PayPalVaultResult) -> Void)? = nil,
        error: ((PayPalWebCheckoutClient, CoreSDKError) -> Void)? = nil,
        cancel: ((PayPalWebCheckoutClient) -> Void)? = nil
    ) {
        self.success = success
        self.failure = error
        self.cancel = cancel
    }

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultResult paypalVaultResult: PayPalVaultResult
    ) {
        success?(paypalWebClient, paypalVaultResult)
    }

    func paypal(
        _ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithVaultError vaultError: CorePayments.CoreSDKError
    ) {
        failure?(paypalWebClient, vaultError)
    }

    func paypalDidCancel(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        cancel?(paypalWebClient)
    }
}
