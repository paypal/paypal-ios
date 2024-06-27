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
        
        // swiftlint:disable line_length
        let urlString = """
       https://account.venmo.com/go/web/paypal?sessionID=uid_175a24f4f8_mtu6mte6mjc&buttonSessionID=uid_767154b397_mtu6mte6mjc&stickinessID=uid_10e16b2838_mtq6nta6mti&parentDomain=https%3A%2F%2Fwww.sandbox.paypal.com&venmoWebUrl=https%3A%2F%2Faccount.venmo.com%2Fgo%2Fweb%2Fpaypal&venmoWebEnabled=true&token=\(request.orderID)&fundingSource=venmo&buyerCountry=US&locale.x=en_US&commit=false&client-metadata-id=uid_175a24f4f8_mtu6mte6mjc&enableFunding.0=venmo&enableFunding.1=card&clientID=\(config.clientID)&env=sandbox&sdkMeta=eyJ1cmwiOiJodHRwczovL3d3dy5wYXlwYWwuY29tL3Nkay9qcz9jb21wb25lbnRzPWJ1dHRvbnMmY2xpZW50LWlkPUFWaGNBUDhURHU1UEZlQXc5N004MTg3Zy1pWVFXOFcwQWh2dlhhTWFXUG9qSlJHR2t1blg4ci1meVBrS0dDdjA5UDgzS0MyZGlqS0xLd3l6JmxvY2FsZT1lbl9VUyZjb21taXQ9ZmFsc2UmZGVidWc9dHJ1ZSZpbnRlbnQ9Y2FwdHVyZSZkaXNhYmxlLWZ1bmRpbmc9cGF5bGF0ZXImZW5hYmxlLWZ1bmRpbmc9dmVubW8sY2FyZCZidXllci1jb3VudHJ5PVVTIiwiYXR0cnMiOnsiZGF0YS1jc3Atbm9uY2UiOiJiV2M3NWp2YnlQVE5RYVpURndnUCsvcVFRKzlnbWYrMVMwb1RydkVqNFllNUowZEgiLCJkYXRhLXVpZCI6InVpZF92dnBsYnp4YW9ucnFndXdncWNtYnBobnVtZ3VsYmcifX0&channel=desktop-web&xcomponent=1&version=\(PayPalCoreConstants.payPalSDKVersion)&pageURL=https%3A%2F%2Fmobile-sdk-demo-site-838cead5d3ab.herokuapp.com%2Fppcp-payments%0A
       """
        print(urlString)
        
        UIApplication.shared.open(URL(string: urlString)!)
        
        
//        webAuthenticationSession.start(
//            url: payPalCheckoutURLComponents,
//            context: self,
//            sessionDidDisplay: { [weak self] didDisplay in
//                if didDisplay {
//                    self?.analyticsService?.sendEvent("paypal-web-payments:browser-presentation:succeeded")
//                } else {
//                    self?.analyticsService?.sendEvent("paypal-web-payments:browser-presentation:failed")
//                }
//            },
//            sessionDidComplete: { url, error in
//                if let error = error {
//                    switch error {
//                    case ASWebAuthenticationSessionError.canceledLogin:
//                        self.notifyCancellation()
//                        return
//                    default:
//                        self.notifyFailure(with: PayPalWebCheckoutClientError.webSessionError(error))
//                        return
//                    }
//                }
//
//                if let url = url {
//                    guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
//                    let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
//                        self.notifyFailure(with: PayPalWebCheckoutClientError.malformedResultError)
//                        return
//                    }
//
//                    let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
//                    self.notifySuccess(for: result)
//                }
//            }
//        )
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

    /// Starts a web session for vaulting PayPal Payment Method
    /// After setupToken successfullly attaches a payment method, you will need to create a payment token with the setup token
    /// - Parameters:
    ///   - vaultRequest: Request created with url for vault approval and setupTokenID
    public func vault(_ vaultRequest: PayPalVaultRequest) {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
        
        
//        webAuthenticationSession.start(
//            url: vaultRequest.url,
//            context: self,
//            sessionDidDisplay: { [weak self] didDisplay in
//                if didDisplay {
//                    self?.analyticsService?.sendEvent("paypal-vault:browser-presentation:succeeded")
//                } else {
//                    self?.analyticsService?.sendEvent("paypal-vault:browser-presentation:failed")
//                }
//            },
//            sessionDidComplete: { url, error in
//                if let error = error {
//                    switch error {
//                    case ASWebAuthenticationSessionError.canceledLogin:
//                        self.notifyVaultCancellation()
//                        return
//                    default:
//                        self.notifyVaultFailure(with: PayPalWebCheckoutClientError.webSessionError(error))
//                        return
//                    }
//                }
//
//                if let url = url {
//                    guard let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
//                    let approvalSessionID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_session_id"),
//                        !tokenID.isEmpty, !approvalSessionID.isEmpty
//                    else {
//                        self.notifyVaultFailure(with: PayPalWebCheckoutClientError.payPalVaultResponseError)
//                        return
//                    }
//
//                    let paypalVaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
//                    self.notifyVaultSuccess(for: paypalVaultResult)
//                }
//            }
//        )
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

    private func notifyVaultSuccess(for result: PayPalVaultResult) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded")
        vaultDelegate?.paypal(self, didFinishWithVaultResult: result)
    }

    private func notifyVaultFailure(with error: CoreSDKError) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
        vaultDelegate?.paypal(self, didFinishWithVaultError: error)
    }

    private func notifyVaultCancellation() {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
        vaultDelegate?.paypalDidCancel(self)
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
