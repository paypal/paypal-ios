import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

public class PayPalWebCheckoutClient: NSObject {

    let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private let networkingClient: NetworkingClient
    private var analyticsService: AnalyticsService?

    /// Initialize a PayPalWebCheckoutClient to process PayPal transaction
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
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `PayPalWebCheckoutResult` with `orderID` and `payerID` are returned and `error` will be `nil`;
    ///   if it fails, `PayPalWebCheckoutResult will be `nil` and `error` will describe the failure
    public func start(request: PayPalWebCheckoutRequest, completion: @escaping (PayPalWebCheckoutResult?, Error?) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:started")
        
        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString =
            "\(baseURLString)/checkoutnow?token=\(request.orderID)" +
            "&fundingSource=\(request.fundingSource.rawValue)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            self.notifyCheckoutFailure(with: PayPalWebCheckoutClientError.payPalURLError, completion: completion)
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
                        self.notifyCheckoutCancelWithError(
                            with: PayPalWebCheckoutClientError.paypalCancellationError,
                            completion: completion
                        )
                        return
                    default:
                        self.notifyCheckoutFailure(with: PayPalWebCheckoutClientError.webSessionError(error), completion: completion)
                        return
                    }
                }

                if let url = url {
                    guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                    let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                        self.notifyCheckoutFailure(with: PayPalWebCheckoutClientError.malformedResultError, completion: completion)
                        return
                    }

                    let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                    self.notifyCheckoutSuccess(for: result, completion: completion)
                }
            }
        )
    }

    /// Launch the PayPal web flow
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    /// - Returns: A `PayPalWebCheckoutResult` if successful
    /// - Throws: An `Error` describing the failure
    public func start(request: PayPalWebCheckoutRequest) async throws -> PayPalWebCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(request: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
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

    /// Starts a web session for vaulting PayPal Payment Method
    /// After setupToken successfullly attaches a payment method, you will need to create a payment token with the setup token
    /// - Parameters:
    ///   - vaultRequest: Request created with url for vault approval and setupTokenID
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `PayPalVaultResult` with `tokenID` and `approvalSessionID` are returned and `error` will be `nil`;
    ///   if it fails, `PayPalVaultResult will be `nil` and `error` will describe the failure
    public func vault(_ vaultRequest: PayPalVaultRequest, completion: @escaping (PayPalVaultResult?, Error?) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
        
        var vaultURLComponents = URLComponents(url: config.environment.paypalVaultCheckoutURL, resolvingAgainstBaseURL: false)
        let queryItems = [URLQueryItem(name: "approval_session_id", value: vaultRequest.setupTokenID)]
        vaultURLComponents?.queryItems = queryItems
        
        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            notifyVaultFailure(with: PayPalWebCheckoutClientError.payPalURLError, completion: completion)
            return
        }
        
        webAuthenticationSession.start(
            url: vaultCheckoutURL,
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
                        self.notifyVaultCancelWithError(
                            with: PayPalWebCheckoutClientError.paypalVaultCancellationError,
                            completion: completion
                        )
                        return
                    default:
                        self.notifyVaultFailure(with: PayPalWebCheckoutClientError.webSessionError(error), completion: completion)
                        return
                    }
                }

                if let url = url {
                    guard let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                    let approvalSessionID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_session_id"),
                        !tokenID.isEmpty, !approvalSessionID.isEmpty
                    else {
                        self.notifyVaultFailure(with: PayPalWebCheckoutClientError.payPalVaultResponseError, completion: completion)
                        return
                    }

                    let paypalVaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
                    self.notifyVaultSuccess(for: paypalVaultResult, completion: completion)
                }
            }
        )
    }

    /// Starts a web session for vaulting PayPal Payment Method
    /// After setupToken successfullly attaches a payment method, you will need to create a payment token with the setup token
    /// - Parameters:
    ///   - vaultRequest: Request created with url for vault approval and setupTokenID
    /// - Returns: `PayPalVaultResult`if successful
    /// - Throws: An `Error` describing failure
    public func vault(_ vaultRequest: PayPalVaultRequest) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(vaultRequest) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifyCheckoutSuccess(for result: PayPalWebCheckoutResult, completion: (PayPalWebCheckoutResult?, Error?) -> Void) {
        self.analyticsService?.sendEvent("paypal-web-payments:succeeded")
        completion(result, nil)
    }

    private func notifyCheckoutFailure(with error: CoreSDKError, completion: (PayPalWebCheckoutResult?, Error?) -> Void) {
        self.analyticsService?.sendEvent("paypal-web-payments:succeeded")
        completion(nil, error)
    }

    private func notifyCheckoutCancelWithError(with error: CoreSDKError, completion: (PayPalWebCheckoutResult?, Error?) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:challenge:browser-login:canceled")
        completion(nil, error)
    }

    private func notifyVaultSuccess(for result: PayPalVaultResult, completion: (PayPalVaultResult?, Error?) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded")
        completion(result, nil)
    }

    private func notifyVaultFailure(with error: CoreSDKError, completion: (PayPalVaultResult?, Error?) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
        completion(nil, error)
    }

    private func notifyVaultCancelWithError(with vaultError: CoreSDKError, completion: (PayPalVaultResult?, Error?) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
        completion(nil, vaultError)
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
