import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

public class PayPalBrandedCardFormClient: NSObject {

    let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private let networkingClient: NetworkingClient
    private var analyticsService: AnalyticsService?

    /// Initialize a PayPalBrandedCardFormClient to process PayPal transaction
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

    /// Launch the PayPal web guest checkout flow
    /// - Parameters:
    ///   - orderID: the Order for the transaction
    ///   - completion: A completion block that is invoked when the request is completed.
    ///                 The closure returns a `Result`:
    ///                 - `.success(CardFormResult)` containing:
    ///                   - `orderID`: The ID of the approved order.
    ///                   - `payerID`: Payer ID (or user id) associated with the transaction
    ///                 - `.failure(CoreSDKError)`: Describes the reason for failure.
    public func start(orderID: String, completion: @escaping (Result<CardFormResult, CoreSDKError>) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)
        analyticsService?.sendEvent("paypal-branded-card-form:checkout:started")

        let baseURLString = config.environment.payPalBaseURL.absoluteString

        let payPalCheckoutURLString =
            "\(baseURLString)/checkoutnow?token=\(orderID)" +
            "&fundingSource=card"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            self.notifyCheckoutFailure(with: CardFormError.payPalURLError, completion: completion)
            return
        }

        webAuthenticationSession.start(
            url: payPalCheckoutURLComponents,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-branded-card-form:checkout:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-branded-card-form:checkout:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { url, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyCheckoutCancelWithError(
                            with: CardFormError.checkoutCanceledError,
                            completion: completion
                        )
                        return
                    default:
                        self.notifyCheckoutFailure(with: CardFormError.webSessionError(error), completion: completion)
                        return
                    }
                }

                if let url = url {
                    guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                    let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                        self.notifyCheckoutFailure(with: CardFormError.malformedResultError, completion: completion)
                        return
                    }

                    let result = CardFormResult(orderID: orderID, payerID: payerID)
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
    public func start(orderID: String) async throws -> CardFormResult {
        try await withCheckedThrowingContinuation { continuation in
            start(orderID: orderID) { result in
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

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifyCheckoutSuccess(
        for result: CardFormResult,
        completion: (Result<CardFormResult, CoreSDKError>) -> Void
    ) {
        self.analyticsService?.sendEvent("paypal-branded-card-form:checkout:succeeded")
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<CardFormResult, CoreSDKError>) -> Void
    ) {
        self.analyticsService?.sendEvent("paypal-branded-card-form:checkout:failed")
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<CardFormResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-branded-card-form:checkout:canceled")
        completion(.failure(error))
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension PayPalBrandedCardFormClient: ASWebAuthenticationPresentationContextProviding {

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
