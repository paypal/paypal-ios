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
    ///   - completion: A completion block that is invoked when the request is completed.
    ///                 The closure returns a `Result`:
    ///                 - `.success(PayPalCheckoutResult)` containing:
    ///                   - `orderID`: The ID of the approved order.
    ///                   - `payerID`: Payer ID (or user id) associated with the transaction
    ///                 - `.failure(CoreSDKError)`: Describes the reason for failure.
    public func start(request: PayPalWebCheckoutRequest, completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:checkout:started")

        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString =
            "\(baseURLString)/checkoutnow?token=\(request.orderID)" +
            "&fundingSource=\(request.fundingSource.rawValue)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            self.notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        
        webAuthenticationSession.start(
            url: payPalCheckoutURLComponents,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-web-payments:checkout:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-web-payments:checkout:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { url, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyCheckoutCancelWithError(
                            with: PayPalError.checkoutCanceledError,
                            completion: completion
                        )
                        return
                    default:
                        self.notifyCheckoutFailure(with: PayPalError.webSessionError(error), completion: completion)
                        return
                    }
                }

                if let url = url {
                    guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                    let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                        self.notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
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
    /// - Throws: A `CoreSDKError` describing the failure
    public func start(request: PayPalWebCheckoutRequest) async throws -> PayPalWebCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(request: request) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
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
    ///                 The closure returns a `PayPalVaultResult`:
    ///                 - `.success(PayPalVaultResult)` containing:
    ///                   - `tokenID`: The ID of the setup token.
    ///                   - `approvalSessionID`: id of the PayPalWebCheckout session
    ///                 - `.failure(CoreSDKError)`: Describes the reason for failure.
    public func vault(_ vaultRequest: PayPalVaultRequest, completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
        
        var vaultURLComponents = URLComponents(url: config.environment.paypalVaultCheckoutURL, resolvingAgainstBaseURL: false)
        let queryItems = [URLQueryItem(name: "approval_session_id", value: vaultRequest.setupTokenID)]
        vaultURLComponents?.queryItems = queryItems
        
        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        
        webAuthenticationSession.start(
            url: vaultCheckoutURL,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { url, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyVaultCancelWithError(
                            with: PayPalError.vaultCanceledError,
                            completion: completion
                        )
                        return
                    default:
                        self.notifyVaultFailure(with: PayPalError.webSessionError(error), completion: completion)
                        return
                    }
                }

                if let url = url {
                    guard let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                    let approvalSessionID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_session_id"),
                        !tokenID.isEmpty, !approvalSessionID.isEmpty
                    else {
                        self.notifyVaultFailure(with: PayPalError.payPalVaultResponseError, completion: completion)
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
    /// - Throws: A `CoreSDKError` describing failure
    public func vault(_ vaultRequest: PayPalVaultRequest) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(vaultRequest) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifyCheckoutSuccess(
        for result: PayPalWebCheckoutResult,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        self.analyticsService?.sendEvent("paypal-web-payments:checkout:succeeded")
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        self.analyticsService?.sendEvent("paypal-web-payments:checkout:failed")
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:canceled")
        completion(.failure(error))
    }

    private func notifyVaultSuccess(for result: PayPalVaultResult, completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded")
        completion(.success(result))
    }

    private func notifyVaultFailure(with error: CoreSDKError, completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
        completion(.failure(error))
    }

    private func notifyVaultCancelWithError(with vaultError: CoreSDKError, completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
        completion(.failure(vaultError))
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
