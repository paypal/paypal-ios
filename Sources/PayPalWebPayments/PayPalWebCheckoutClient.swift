import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

// swiftlint: disable type_body_length file_length
public class PayPalWebCheckoutClient: NSObject {
    
    enum PayPalCheckoutCallbackURL {
        static let path = "x-callback-url/paypal-sdk/paypal-checkout"
        static let redirectURL = "\(PayPalCoreConstants.callbackURLScheme)://\(path)"
    }

    static let serialDispatchQueue =
        DispatchQueue(label: "com.paypal.ios.PayPalWebCheckoutClient.serialDispatchQueue")
    
    let config: CoreConfig

    var appSwitchCompletion: ((Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void)?
    var vaultAppSwitchCompletion: ((Result<PayPalVaultResult, CoreSDKError>) -> Void)?
    var urlOpener: URLOpener = UIApplication.shared

    private let clientConfigAPI: UpdateClientConfigAPI
    private let webAuthenticationSession: WebAuthenticationSession
    private let networkingClient: NetworkingClient
    private let patchCCOAPI: PatchCCOWithAppSwitchEligibility
    private let createShopperSessionAPI: CreateShopperSessionAPI
    private var analyticsService: AnalyticsService?

    /// Holds the in-flight or completed Shopper Session fetch.
    /// Set by `createPayPalSession()`. Cleared automatically on checkout success, cancellation, or error.
    private var sessionTask: Task<ShopperSessionResult, Error>?

    // MARK: - Initializer

    /// Initialize a `PayPalWebCheckoutClient` to process PayPal transactions.
    /// - Parameter config: The `CoreConfig` object.
    public init(config: CoreConfig) {
        self.config = config
        self.webAuthenticationSession = WebAuthenticationSession()
        self.networkingClient = NetworkingClient(coreConfig: config)
        self.clientConfigAPI = UpdateClientConfigAPI(coreConfig: config)
        self.patchCCOAPI = PatchCCOWithAppSwitchEligibility(coreConfig: config)
        self.createShopperSessionAPI = CreateShopperSessionAPI(coreConfig: config)
    }

    /// For internal use for testing/mocking purposes.
    init(
        config: CoreConfig,
        networkingClient: NetworkingClient,
        clientConfigAPI: UpdateClientConfigAPI,
        patchCCOAPI: PatchCCOWithAppSwitchEligibility,
        createShopperSessionAPI: CreateShopperSessionAPI,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        self.config = config
        self.webAuthenticationSession = webAuthenticationSession
        self.networkingClient = networkingClient
        self.clientConfigAPI = clientConfigAPI
        self.patchCCOAPI = patchCCOAPI
        self.createShopperSessionAPI = createShopperSessionAPI
    }

    // MARK: - Session Creation

    /// Pre-warms the Shopper Session in the background. **Must be called before `start()` or `vault()`.**
    ///
    /// This is a fire-and-forget method — it returns immediately while the session fetch runs asynchronously.
    /// Call it early (e.g. on cart-page load or button render) to minimise latency when the buyer taps checkout.
    ///
    /// If called again while a previous session fetch is still in flight, the previous task is cancelled
    /// and a new one is started.
    ///
    /// Fires analytics events:
    /// - `paypal-web-payments:create-paypal-session:started`
    /// - `paypal-web-payments:create-paypal-session:succeeded`
    /// - `paypal-web-payments:create-paypal-session:failed`
    ///
    /// - Parameters:
    ///   - userIdentity: Optional buyer identity. Defaults to `nil`.
    ///   - urlConfig: Return and cancel deep-link URLs registered with PayPal.
    ///   - userAction: The buyer action intent. Defaults to `.continue`.
    public func createPayPalSession(
        userIdentity: PayPalUserIdentity? = nil,
        urlConfig: PayPalURLConfig,
        userAction: PayPalUserAction = .continue
    ) {
        sessionTask?.cancel()

        sessionTask = Task {
            try await createShopperSessionAPI.createShopperSessionWithAppSwitchEligibility(
                urlConfig: urlConfig,
                userIdentity: userIdentity,
                userAction: userAction
            )
        }
    }

    // MARK: - Checkout

    /// Initiates the PayPal checkout flow.
    ///
    /// `createPayPalSession()` **must** be called before this method. If not, the completion is
    /// called immediately with `PayPalError.sessionNotStartedError`.
    ///
    /// If the session fetch is still in progress, this method suspends until it completes before
    /// launching the checkout UI.
    ///
    /// - Parameters:
    ///   - orderID: The order ID to approve.
    ///   - completion: A completion block invoked on the main thread with a `Result`:
    ///     - `.success(PayPalWebCheckoutResult)` — `orderID` and `payerID` on approval.
    ///     - `.failure(CoreSDKError)` — describes the failure reason.
    public func start(
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        guard let task = sessionTask else {
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)

        Task {
            do {
                let session = try await task.value
                sessionTask = nil
                analyticsService?.sendEvent("paypal-web-payments:checkout:started")
                launchCheckout(session: session, orderID: orderID, completion: completion)
            } catch {
                sessionTask = nil
                let sdkError = sdkError(from: error, fallback: "Session fetch failed.")
                analyticsService?.sendEvent("paypal-web-payments:checkout:failed")
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        }
    }

    // MARK: - Vault

    /// Initiates the PayPal vault flow for saving a payment method without a purchase.
    ///
    /// `createPayPalSession()` **must** be called before this method. If not, the completion is
    /// called immediately with `PayPalError.sessionNotStartedError`.
    ///
    /// After the setup token successfully attaches a payment method, create a payment token
    /// with the setup token via your server.
    ///
    /// - Parameters:
    ///   - setupTokenID: The setup token ID returned by the PayPal setup-token API.
    ///   - completion: A completion block invoked on the main thread with a `Result`:
    ///     - `.success(PayPalVaultResult)` — `tokenID` and `approvalSessionID` on success.
    ///     - `.failure(CoreSDKError)` — describes the failure reason.
    public func vault(
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        guard let task = sessionTask else {
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = AnalyticsService(coreConfig: config, setupToken: setupTokenID)

        Task {
            do {
                _ = try await task.value
                sessionTask = nil
                analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
                startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completion)
            } catch {
                sessionTask = nil
                let sdkError = sdkError(from: error, fallback: "Session fetch failed.")
                analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        }
    }

    // MARK: - Deprecated API


    /// - Warning: Deprecated. Use `createPayPalSession(userIdentity:urlConfig:userAction:)` followed
    ///   by `start(orderID:completion:)` instead.
    @available(*, deprecated, renamed: "start(orderID:completion:)")
    public func start(
        request: PayPalWebCheckoutRequest,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:checkout:started")

        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        Task {
            if request.appSwitchIfEligible && appInstalled {
                let result = await attemptAppSwitchIfEligible(
                    request: request,
                    paypalNativeAppInstalled: appInstalled,
                    completionOnce: completionOnce
                )
                switch result {
                case .launched:
                    // Do nothing here. We will complete when handleReturnURL is invoked.
                    return

                case .fallback(let reason):
                    analyticsService?.sendEvent("paypal-web-payments:checkout:fallback-to-web:\(reason)")
                    startWebCheckoutFlow(
                        orderID: request.orderID,
                        fundingSource: request.fundingSource,
                        completion: completionOnce
                    )
                }
            } else {
                startWebCheckoutFlow(
                    orderID: request.orderID,
                    fundingSource: request.fundingSource,
                    completion: completionOnce
                )
            }
        }
    }

    /// - Warning: Deprecated. Use `createPayPalSession(userIdentity:urlConfig:userAction:)` followed
    ///   by `start(orderID:)` instead.
    @available(*, deprecated, renamed: "start(orderID:)")
    public func start(request: PayPalWebCheckoutRequest) async throws -> PayPalWebCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(request: request) { result in
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    /// - Warning: Deprecated. Use `createPayPalSession(userIdentity:urlConfig:userAction:)` followed
    ///   by `vault(setupTokenID:completion:)` instead.
    @available(*, deprecated, renamed: "vault(setupTokenID:completion:)")
    public func vault(
        _ vaultRequest: PayPalVaultRequest,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
        startVaultWebAuthFlow(setupTokenID: vaultRequest.setupTokenID, completion: completion)
    }

    /// - Warning: Deprecated. Use `createPayPalSession(userIdentity:urlConfig:userAction:)` followed
    ///   by `vault(setupTokenID:)` instead.
    @available(*, deprecated, renamed: "vault(setupTokenID:)")
    public func vault(_ vaultRequest: PayPalVaultRequest) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(vaultRequest) { result in
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - App Switch

    /// Routes a PayPal deep-link return URL back to the active checkout or vault flow.
    /// Call this from your `UIApplicationDelegate` or `Scene` delegate when a PayPal URL is received.
    public func handleReturnURL(_ url: URL) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []
        func queryValue(_ name: String) -> String? {
            items.first { $0.name.compare(name) == .orderedSame }?.value
        }

        let path = url.path.lowercased()
        let isCancel = path.contains("/cancel")

        let vaultTokenID = queryValue("approval_token_id")
        let vaultSessionID = queryValue("approval_session_id")
        let hasVaultSuccess = (vaultTokenID?.isEmpty == false) && (vaultSessionID?.isEmpty == false)

        let orderID = queryValue("token")
        let payerID = queryValue("PayerID")
        let hasCheckoutSuccess = (orderID?.isEmpty == false) && (payerID?.isEmpty == false)

        if isCancel {
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                sessionTask = nil
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
                return
            }
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                sessionTask = nil
                notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
                return
            }
            return
        }

        if hasVaultSuccess, let tokenID = vaultTokenID, let sessionID = vaultSessionID {
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                sessionTask = nil
                let result = PayPalVaultResult(tokenID: tokenID, approvalSessionID: sessionID)
                notifyVaultSuccess(for: result, completion: completion)
                return
            }
        }

        if hasCheckoutSuccess, let oid = orderID, let pid = payerID {
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                sessionTask = nil
                let result = PayPalWebCheckoutResult(orderID: oid, payerID: pid)
                notifyCheckoutSuccess(for: result, completion: completion)
                return
            }
        }

        if let completion = vaultAppSwitchCompletion {
            vaultAppSwitchCompletion = nil
            sessionTask = nil
            notifyVaultFailure(with: PayPalError.malformedResultError, completion: completion)
        } else if let completion = appSwitchCompletion {
            appSwitchCompletion = nil
            sessionTask = nil
            notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
        }
    }

    // MARK: - Private: Session-based Launch

    private func launchCheckout(
        session: ShopperSessionResult,
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        Task {
            if appInstalled,
               session.appSwitchEligible,
               let base = session.redirectURL,
               let sessionID = session.shopperSessionConfig?.id,
               let url = URL(string: PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                   base: base,
                   orderID: orderID,
                   clientID: config.clientID,
                   sessionID: sessionID
               )) {
                let result = await attemptSessionAppSwitch(url: url, completionOnce: completionOnce)
                switch result {
                case .launched:
                    return
                case .fallback(let reason):
                    analyticsService?.sendEvent("paypal-web-payments:checkout:fallback-to-web:\(reason)")
                }
            }
            startWebCheckoutFlow(orderID: orderID, fundingSource: .paypal, completion: completionOnce)
        }
    }

    private func launchVault(
        session: ShopperSessionResult,
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        Task {
            if appInstalled,
               session.appSwitchEligible,
               let base = session.redirectURL,
               let sessionID = session.shopperSessionConfig?.id,
               let url = URL(string: PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
                   base: base,
                   setupTokenID: setupTokenID,
                   clientID: config.clientID,
                   sessionID: sessionID
               )) {
                let result = await attemptSessionVaultAppSwitch(url: url, completionOnce: completionOnce)
                switch result {
                case .launched:
                    return
                case .fallback(let reason):
                    analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:fallback-to-web:\(reason)")
                }
            }
            startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completionOnce)
        }
    }

    // MARK: - Private: App Switch (Session-based)

    private enum AppSwitchAttempt { case launched, fallback(String) }

    /// Attempts a session-based app switch to the PayPal app using the redirect URL from the session response.
    private func attemptSessionAppSwitch(
        url: URL,
        completionOnce: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async -> AppSwitchAttempt {
        await MainActor.run {
            appSwitchCompletion = completionOnce
        }
        let opened = await attemptAppSwitch(with: url)
        if opened {
            analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:succeeded")
            return .launched
        } else {
            analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:failed")
            await MainActor.run { [weak self] in
                self?.appSwitchCompletion = nil
            }
            return .fallback("cannot_open_url")
        }
    }

    /// Attempts a session-based app switch to the PayPal app for the vault-without-purchase flow,
    /// using the redirect URL from the session response.
    private func attemptSessionVaultAppSwitch(
        url: URL,
        completionOnce: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async -> AppSwitchAttempt {
        await MainActor.run {
            vaultAppSwitchCompletion = completionOnce
        }
        let opened = await attemptAppSwitch(with: url)
        if opened {
            analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:app-switch-open:succeeded")
            return .launched
        } else {
            analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:app-switch-open:failed")
            await MainActor.run { [weak self] in
                self?.vaultAppSwitchCompletion = nil
            }
            return .fallback("cannot_open_url")
        }
    }

    // MARK: - Private: Web Auth Flows

    private func startWebCheckoutFlow(
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        Task {
            do {
                _ = try await clientConfigAPI.updateClientConfig(
                    token: orderID,
                    fundingSource: fundingSource.rawValue
                )
            } catch {
                print("updateClientConfig error: \(error.localizedDescription)")
            }

            let baseURLString = config.environment.payPalBaseURL.absoluteString
            let payPalCheckoutURLString = "\(baseURLString)/checkoutnow?token=\(orderID)" +
                "&fundingSource=\(fundingSource.rawValue)&integration_artifact=MOBILE_SDK"

            guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
                let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
            else {
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            webAuthenticationSession.start(
                url: payPalCheckoutURLComponents,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    let event = didDisplay
                        ? "paypal-web-payments:checkout:auth-challenge-presentation:succeeded"
                        : "paypal-web-payments:checkout:auth-challenge-presentation:failed"
                    self?.analyticsService?.sendEvent(event)
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    if let error {
                        let sdkError: CoreSDKError
                        switch error {
                        case ASWebAuthenticationSessionError.canceledLogin:
                            sdkError = PayPalError.checkoutCanceledError
                        default:
                            sdkError = PayPalError.webSessionError(error)
                        }
                        self.sessionTask = nil
                        self.notifyCheckoutFailure(with: sdkError, completion: completion)
                    }

                    if let url {
                        if let opType = self.getQueryStringParameter(url: url.absoluteString, param: "opType"),
                            opType == "cancel" {
                            self.sessionTask = nil
                            self.notifyCheckoutCancelWithError(
                                with: PayPalError.checkoutCanceledError, completion: completion
                            )
                        } else if let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                            let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") {
                            self.sessionTask = nil
                            let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                            self.notifyCheckoutSuccess(for: result, completion: completion)
                        } else {
                            self.sessionTask = nil
                            self.notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
                        }
                    }
                }
            )
        }
    }

    private func startVaultWebAuthFlow(
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        let vaultURL = config.environment.paypalVaultCheckoutURL
        var vaultURLComponents = URLComponents(url: vaultURL, resolvingAgainstBaseURL: false)
        let queryItems = [
            URLQueryItem(name: "approval_session_id", value: setupTokenID),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]
        vaultURLComponents?.queryItems = queryItems

        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }

        webAuthenticationSession.start(
            url: vaultCheckoutURL,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                let event = didDisplay
                    ? "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
                    : "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed"
                self?.analyticsService?.sendEvent(event)
            },
            sessionDidComplete: { [weak self] url, error in
                guard let self else { return }
                if let error {
                    let sdkError: CoreSDKError
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        sdkError = PayPalError.vaultCanceledError
                    default:
                        sdkError = PayPalError.webSessionError(error)
                    }
                    self.sessionTask = nil
                    self.notifyVaultCancelWithError(with: sdkError, completion: completion)
                }

                if let url {
                    if url.path.contains("cancel") {
                        self.sessionTask = nil
                        self.notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
                    } else if
                        let tokenID = self.getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                        let approvalSessionID = self.getQueryStringParameter(
                            url: url.absoluteString, param: "approval_session_id"
                        ),
                        !tokenID.isEmpty, !approvalSessionID.isEmpty {
                        self.sessionTask = nil
                        let vaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
                        self.notifyVaultSuccess(for: vaultResult, completion: completion)
                    } else {
                        self.sessionTask = nil
                        self.notifyVaultFailure(with: PayPalError.payPalVaultResponseError, completion: completion)
                    }
                }
            }
        )
    }

    private func attemptAppSwitchIfEligible(
        request: PayPalWebCheckoutRequest,
        paypalNativeAppInstalled: Bool = true,
        completionOnce: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async -> AppSwitchAttempt {
        do {
            let eligibility = try await patchCCOAPI.patchCCOWithAppSwitchEligibility(
                token: request.orderID,
                tokenType: ExternalTokenKind.orderId,
                canSwitchToApp: paypalNativeAppInstalled
            )

            guard eligibility.appSwitchEligible == true,
                let urlString = eligibility.redirectURL,
                let url = URL(string: urlString)
            else {
                return .fallback(eligibility.ineligibleReason ?? "ineligible")
            }

            return await attemptSessionAppSwitch(url: url, completionOnce: completionOnce)
        } catch {
            analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-eligibility:error")
            return .fallback("patch_or_lsat_failed")
        }
    }

    @MainActor
    private func attemptAppSwitch(with url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            urlOpener.open(url) { success in
                continuation.resume(returning: success)
            }
        }
    }

    // MARK: - Private: Single-shot Completion Wrapper

    private func makeCompletionOnce<T>(
        _ completion: @escaping (Result<T, CoreSDKError>) -> Void
    ) -> (Result<T, CoreSDKError>) -> Void {
        var shouldInvokeCompletion = true
        return { result in
            Self.serialDispatchQueue.async {
                guard shouldInvokeCompletion else { return }
                shouldInvokeCompletion = false
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    // MARK: - Private: URL Helpers

    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
        let redirectURLString = PayPalCheckoutCallbackURL.redirectURL
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

    // MARK: - Private: Error Helper

    private func sdkError(from error: Error, fallback message: String) -> CoreSDKError {
        (error as? CoreSDKError) ?? CoreSDKError(
            code: PayPalError.Code.unknown.rawValue,
            domain: PayPalError.domain,
            errorDescription: error.localizedDescription.isEmpty ? message : error.localizedDescription
        )
    }

    // MARK: - Private: Notify Helpers

    private func notifyCheckoutSuccess(
        for result: PayPalWebCheckoutResult,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:succeeded")
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:failed")
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:canceled")
        completion(.failure(error))
    }

    private func notifyVaultSuccess(
        for result: PayPalVaultResult,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded")
        completion(.success(result))
    }

    private func notifyVaultFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:failed")
        completion(.failure(error))
    }

    private func notifyVaultCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
        completion(.failure(error))
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
// swiftlint:enable type_body_length file_length
