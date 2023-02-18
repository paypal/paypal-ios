import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

public class PayPalWebCheckoutClient: NSObject {

    public weak var delegate: PayPalWebCheckoutDelegate?
    let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private let apiClient: APIClient
    
    /// Initialize a PayPalNativeCheckoutClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.webAuthenticationSession = WebAuthenticationSession()
        self.apiClient = APIClient(coreConfig: config)
    }
    
    /// For internal use for testing/mocking purpose
    init(config: CoreConfig, apiClient: APIClient, webAuthenticationSession: WebAuthenticationSession) {
        self.config = config
        self.webAuthenticationSession = webAuthenticationSession
        self.apiClient = apiClient
    }

    /// Launch the PayPal web flow
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    public func start(request: PayPalWebCheckoutRequest) {
        apiClient.sendAnalyticsEvent("paypal-web-payments:started")
        
        Task {
            do {
                _ = try await apiClient.fetchCachedOrRemoteClientID()
            } catch {
                notifyFailure(with: CorePaymentsError.clientIDNotFoundError)
                return
            }
        }
        
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

        webAuthenticationSession.start(url: payPalCheckoutURLComponents, context: self) { url, error in
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

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifySuccess(for result: PayPalWebCheckoutResult) {
        let payPalResult = PayPalWebCheckoutResult(orderID: result.orderID, payerID: result.payerID)
        apiClient.sendAnalyticsEvent("paypal-web-payments:succeeded")
        delegate?.payPal(self, didFinishWithResult: payPalResult)
    }

    private func notifyFailure(with error: CoreSDKError) {
        apiClient.sendAnalyticsEvent("paypal-web-payments:failed")
        delegate?.payPal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        apiClient.sendAnalyticsEvent("paypal-web-payments:browser-login:canceled")
        delegate?.payPalDidCancel(self)
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
