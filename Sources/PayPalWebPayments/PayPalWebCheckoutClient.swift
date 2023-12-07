import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

public class PayPalWebCheckoutClient: NSObject {

    public weak var vaultDelegate: PayPalVaultDelegate?
    public weak var delegate: PayPalWebCheckoutDelegate?
    let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private let networkingClient: NetworkingClient
    private var analyticsService: AnalyticsService?

    /// Initialize a PayPalNativeCheckoutClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.webAuthenticationSession = WebAuthenticationSession()
        self.networkingClient = NetworkingClient(coreConfig: config)
    }
    
    /// For internal use for testing/mocking purpose
    init(config: CoreConfig, networkingClient: NetworkingClient, webAuthenticationSession: WebAuthenticationSession) {
        self.config = config
        self.webAuthenticationSession = webAuthenticationSession
        self.networkingClient = networkingClient
    }

    /// Launch the PayPal web flow
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    public func start(request: PayPalWebCheckoutRequest) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:started")
        
        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString =
            "\(baseURLString)/checkoutnow?token=\(request.orderID)" +
            "&fundingSource=\(request.fundingSource.rawValue)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            self.notifyFailure(with: PayPalWebCheckoutClientError.payPalURLError)
            return
        }
        
        webAuthenticationSession.start(
            url: payPalCheckoutURLComponents,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-web-payments:browser-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-web-payments:browser-presentation:failed")
                }
            },
            sessionDidComplete: { url, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyCancellation()
                        return
                    default:
                        self.notifyFailure(with: PayPalWebCheckoutClientError.webSessionError(error))
                        return
                    }
                }

                if let url = url {
                    guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                    let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                        self.notifyFailure(with: PayPalWebCheckoutClientError.malformedResultError)
                        return
                    }

                    let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                    self.notifySuccess(for: result)
                }
            }
        )
    }

    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
        let bundleID = PayPalCoreConstants.callbackURLScheme
        let redirectURLString = "\(bundleID)://x-callback-url/paypal-sdk/paypal-checkout"
        let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: redirectURLString)
        let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")

        var checkoutURLComponents = URLComponents(url: payPalCheckoutURL, resolvingAgainstBaseURL: false)
        checkoutURLComponents?.queryItems?.append(redirectQueryItem)
        checkoutURLComponents?.queryItems?.append(nativeXOQueryItem)

        return checkoutURLComponents?.url
    }

    public func vault(url: URL) {
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-vault:browser-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-vault:browser-presentation:failed")
                }
            },
            sessionDidComplete: { url, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyVaultCancellation()
                        return
                    default:
                        self.notifyVaultFailure(with: PayPalWebCheckoutClientError.webSessionError(error))
                        return
                    }
                }

                if let url, let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id") {
                    self.notifyVaultSuccess(for: tokenID)
                } else {
                    self.notifyVaultFailure(with: PayPalWebCheckoutClientError.payPalVaultResponseError)
                }
            }
        )
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifySuccess(for result: PayPalWebCheckoutResult) {
        let payPalResult = PayPalWebCheckoutResult(orderID: result.orderID, payerID: result.payerID)
        analyticsService?.sendEvent("paypal-web-payments:succeeded")
        delegate?.payPal(self, didFinishWithResult: payPalResult)
    }

    private func notifyFailure(with error: CoreSDKError) {
        analyticsService?.sendEvent("paypal-web-payments:failed")
        delegate?.payPal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        analyticsService?.sendEvent("paypal-web-payments:browser-login:canceled")
        delegate?.payPalDidCancel(self)
    }

    private func notifyVaultSuccess(for result: String) {
        vaultDelegate?.paypal(self, didFinishWithVaultResult: result)
    }

    private func notifyVaultFailure(with error: CoreSDKError) {
        analyticsService?.sendEvent("paypal-web-payments:failed")
        vaultDelegate?.paypal(self, didFinishWithVaultError: error)
    }

    private func notifyVaultCancellation() {
        print("PayPal Vault Cancelled.")
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension PayPalWebCheckoutClient: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
