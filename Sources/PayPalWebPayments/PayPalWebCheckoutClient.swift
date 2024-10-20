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
    /// - Returns: A `PayPalWebCheckoutResult` with `orderID` and a `payerID`
    /// - Throws: An `Error` describing the failure
    public func start(request: PayPalWebCheckoutRequest) async throws -> PayPalWebCheckoutResult {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:started")

        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString =
        "\(baseURLString)/checkoutnow?token=\(request.orderID)" +
        "&fundingSource=\(request.fundingSource.rawValue)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
            let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            analyticsService?.sendEvent("paypal-web-payments:failed")
            throw PayPalWebCheckoutClientError.payPalURLError
        }

        return try await withCheckedThrowingContinuation { continuation in
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
                            self.analyticsService?.sendEvent("paypal-web-payments:browser-login:canceled")
                            continuation.resume(throwing: PayPalWebCheckoutClientError.paypalCancellation)
                        default:
                            self.analyticsService?.sendEvent("paypal-web-payments:failed")
                            continuation.resume(throwing: PayPalWebCheckoutClientError.webSessionError(error))
                        }
                    }

                    if let url = url {
                        guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                            let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                            self.analyticsService?.sendEvent("paypal-web-payments:failed")
                            continuation.resume(throwing: PayPalWebCheckoutClientError.malformedResultError)
                            return
                        }

                        let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                        self.analyticsService?.sendEvent("paypal-web-payments:succeeded")
                        continuation.resume(returning: result)
                    }
                }
            )
        }
    }

    /// Launch the PayPal web flow
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `PayPalWebCheckoutResult` with `orderID` and `payerID` is returned and `error` will be `nil`;
    ///   if it fails, `PayPalWebCheckoutResult` will be nil and `error` will describe the failure
    public func start(request: PayPalWebCheckoutRequest, completion: @escaping (PayPalWebCheckoutResult?, Error?) -> Void) {
        Task {
            do {
                let result = try await start(request: request)
                completion(result, nil)
            } catch {
                completion(nil, error)
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
    /// - Returns: A `PayPalVaultResult` with `tokenID` and `approvalSessionID`
    /// - Throws: An `Error` describing the failure
    public func vault(_ vaultRequest: PayPalVaultRequest) async throws -> PayPalVaultResult {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")

        var vaultURLComponents = URLComponents(url: config.environment.paypalVaultCheckoutURL, resolvingAgainstBaseURL: false)
        let queryItems = [URLQueryItem(name: "approval_session_id", value: vaultRequest.setupTokenID)]
        vaultURLComponents?.queryItems = queryItems

        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
            throw PayPalWebCheckoutClientError.payPalURLError
        }

        return try await withCheckedThrowingContinuation { continuation in
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
                            self.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
                            continuation.resume(throwing: PayPalWebCheckoutClientError.paypalCancellation)
                        default:
                            self.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
                            continuation.resume(throwing: PayPalWebCheckoutClientError.webSessionError(error))
                        }
                    } else if let url = url,
                        let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                            let approvalSessionID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_session_id"),
                            !tokenID.isEmpty, !approvalSessionID.isEmpty {
                        let paypalVaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
                        self.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded")
                        continuation.resume(returning: paypalVaultResult)
                    } else {
                        self.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
                        continuation.resume(throwing: PayPalWebCheckoutClientError.payPalVaultResponseError)
                    }
                }
            )
        }
    }

    /// Starts a web session for vaulting PayPal Payment Method
    /// After setupToken successfullly attaches a payment method, you will need to create a payment token with the setup token
    /// - Parameters:
    ///   - vaultRequest: Request created with url for vault approval and setupTokenID
    ///   - completion: A completion blokc that is invoked when the request is completed. If the request succeeds,
    ///   a `PayPalVaultResult` with `tokenID` and `approvalSessionID` is returned and `error` will be `nil`;
    ///   if it fails, `PayPalVaultResult` will be `nil` and `error will describe the failure`
    public func vault(_ vaultRequest: PayPalVaultRequest, completion: @escaping (PayPalVaultResult?, Error?) -> Void) {
        Task {
            do {
                let vaultResult = try await vault(vaultRequest)
                completion(vaultResult, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
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
