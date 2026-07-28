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

    /// The token type set by `createPayPalSession()` (or, for the deprecated APIs that don't call it,
    /// set directly by `start(request:completion:)`/`vault(_:completion:)`). Determines the
    /// query-parameter name used to carry the token in app-switch and web checkout/fallback URLs
    /// (see `TokenType.tokenQueryParameterName`). If `nil` when a session-based app-switch URL is
    /// built, that URL build is treated as failed and the flow falls back to the web-based flow
    /// rather than crashing.
    private var tokenType: TokenType?

    // MARK: - Analytics State
    private var analyticsData: PayPalCheckoutAnalyticsData?

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
        
        analyticsService = AnalyticsService(coreConfig: config)
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
    ///   - sessionType: Whether this session is for a checkout or a vault-without-purchase flow.
    ///   - userIdentity: Optional buyer identity. Defaults to `nil`.
    ///   - urlConfig: Return and cancel deep-link URLs registered with PayPal.
    ///   - userAction: The buyer action intent. Defaults to `.continue`.
    public func createPayPalSession(
        sessionType: PayPalSessionType,
        userIdentity: PayPalUserIdentity? = nil,
        urlConfig: PayPalURLConfig,
        userAction: PayPalUserAction = .continue
    ) {
        sessionTask?.cancel()

        let tokenType = sessionType.tokenType
        self.tokenType = tokenType
        analyticsData = PayPalCheckoutAnalyticsData(userIdentity: userIdentity, urlConfig: urlConfig, userAction: userAction)
        analyticsService?.sendEvent("paypal-web-payments:checkout:ssid-session:started")

        sessionTask = Task {
            try await createShopperSessionAPI.createShopperSessionWithAppSwitchEligibility(
                tokenType: tokenType,
                urlOpener: urlOpener,
                urlConfig: urlConfig,
                userIdentity: userIdentity
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
            analyticsService?.sendEvent(
                "paypal-web-payments:checkout:session-not-started",
                errorDescription: PayPalError.sessionNotStartedError.errorDescription,
                checkoutAnalyticsData: analyticsData
            )
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)

        Task {
            do {
                defer {
                    sessionTask = nil
                }

                let session = try await task.value
                analyticsData?.update(with: session, isVault: false)
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:succeeded",
                    checkoutAnalyticsData: analyticsData
                )
                analyticsService?.sendEvent("paypal-web-payments:checkout:started", checkoutAnalyticsData: analyticsData)
                launchCheckout(session: session, orderID: orderID, completion: completion)
            } catch {
                sessionTask = nil
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:failed",
                    errorDescription: error.localizedDescription,
                    checkoutAnalyticsData: analyticsData
                )
                await fallBackToPatchCCOOrWeb(session: nil, orderID: orderID, completion: completion)
            }
        }
    }

    /// Falls back to the legacy PatchCCO app-switch-eligibility check (and, if that's not eligible or
    /// fails to launch, to the web auth flow) when the Shopper Session fetch itself fails, so a session
    /// fetch error doesn't fail checkout outright if app-switch or web checkout can still recover it.
    private func fallBackToPatchCCOOrWeb(
        session: ShopperSessionResult?,
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        guard appInstalled else {
            startWebCheckoutFlow(session: session, orderID: orderID, fundingSource: .paypal, completion: completionOnce)
            return
        }

        let result = await attemptAppSwitchIfEligible(
            token: orderID,
            tokenType: ExternalTokenKind.orderId,
            handlers: SessionAppSwitchHandlers(
                completionOnce: completionOnce,
                setCompletion: { [weak self] in self?.appSwitchCompletion = $0 },
                eventPrefix: "paypal-web-payments:checkout"
            ),
            paypalNativeAppInstalled: appInstalled
        )
        switch result {
        case .launched:
            // Do nothing here. We will complete when handleReturnURL is invoked.
            return
        case .fallback(let reason):
            analyticsService?.sendEvent("paypal-web-payments:checkout:fallback-to-web:\(reason)")
            startWebCheckoutFlow(session: session, orderID: orderID, fundingSource: .paypal, completion: completionOnce)
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
            analyticsService?.sendEvent(
                "paypal-web-payments:vault-wo-purchase:session-not-started",
                errorDescription: PayPalError.sessionNotStartedError.errorDescription,
                checkoutAnalyticsData: analyticsData
            )
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = AnalyticsService(coreConfig: config, setupToken: setupTokenID)

        Task {
            do {
                defer {
                    sessionTask = nil
                }

                let session = try await task.value
                analyticsData?.update(with: session, isVault: true)
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:succeeded",
                    checkoutAnalyticsData: analyticsData
                )
                analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started", checkoutAnalyticsData: analyticsData)
                launchVault(session: session, setupTokenID: setupTokenID, completion: completion)
            } catch {
                sessionTask = nil
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:failed",
                    errorDescription: error.localizedDescription,
                    checkoutAnalyticsData: analyticsData
                )
                await fallBackToPatchCCOOrWebForVault(session: nil, setupTokenID: setupTokenID, completion: completion)
            }
        }
    }

    /// Falls back to the legacy PatchCCO app-switch-eligibility check (and, if that's not eligible or
    /// fails to launch, to the vault web auth flow) when the Shopper Session fetch itself fails, so a
    /// session fetch error doesn't fail vault outright if app-switch or web vault can still recover it.
    /// Mirrors `fallBackToPatchCCOOrWeb`, but checks eligibility for `setupTokenID` under
    /// `ExternalTokenKind.vaultId` (per Android's equivalent implementation) instead of an order ID.
    private func fallBackToPatchCCOOrWebForVault(
        session: ShopperSessionResult?,
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        guard appInstalled else {
            startVaultWebAuthFlow(session: session, setupTokenID: setupTokenID, completion: completionOnce)
            return
        }

        let result = await attemptAppSwitchIfEligible(
            token: setupTokenID,
            tokenType: ExternalTokenKind.vaultId,
            handlers: SessionAppSwitchHandlers(
                completionOnce: completionOnce,
                setCompletion: { [weak self] in self?.vaultAppSwitchCompletion = $0 },
                eventPrefix: "paypal-web-payments:vault-wo-purchase"
            ),
            paypalNativeAppInstalled: appInstalled
        )
        switch result {
        case .launched:
            // Do nothing here. We will complete when handleReturnURL is invoked.
            return
        case .fallback(let reason):
            analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:fallback-to-web:\(reason)")
            startVaultWebAuthFlow(session: session, setupTokenID: setupTokenID, completion: completionOnce)
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
        tokenType = .orderID

        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        Task {
            if request.appSwitchIfEligible && appInstalled {
                let result = await attemptAppSwitchIfEligible(
                    token: request.orderID,
                    tokenType: ExternalTokenKind.orderId,
                    handlers: SessionAppSwitchHandlers(
                        completionOnce: completionOnce,
                        setCompletion: { [weak self] in self?.appSwitchCompletion = $0 },
                        eventPrefix: "paypal-web-payments:checkout"
                    ),
                    paypalNativeAppInstalled: appInstalled
                )
                switch result {
                case .launched:
                    // Do nothing here. We will complete when handleReturnURL is invoked.
                    return

                case .fallback(let reason):
                    analyticsService?.sendEvent("paypal-web-payments:checkout:fallback-to-web:\(reason)")
                    startWebCheckoutFlow(
                        session: nil,
                        orderID: request.orderID,
                        fundingSource: request.fundingSource,
                        completion: completionOnce
                    )
                }
            } else {
                startWebCheckoutFlow(
                    session: nil,
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
        tokenType = .vaultID
        startVaultWebAuthFlow(session: nil, setupTokenID: vaultRequest.setupTokenID, completion: completion)
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

    // swiftlint:disable function_body_length
    /// Routes a PayPal deep-link return URL back to the active checkout or vault flow.
    /// Call this from your `UIApplicationDelegate` or `Scene` delegate when a PayPal URL is received.
    public func handleReturnURL(_ url: URL) {
        defer {
            analyticsData = nil
            sessionTask = nil
        }

        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:handle-return:started",
            checkoutAnalyticsData: analyticsData
        )
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
            analyticsService?.sendEvent(
                "paypal-web-payments:checkout:handle-return:succeeded",
                checkoutAnalyticsData: analyticsData
            )
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
                return
            }
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:app-switch:canceled",
                    checkoutAnalyticsData: analyticsData
                )
                notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
                return
            }
            return
        }

        if hasVaultSuccess, let tokenID = vaultTokenID, let sessionID = vaultSessionID {
            analyticsService?.sendEvent(
                "paypal-web-payments:checkout:handle-return:succeeded",
                checkoutAnalyticsData: analyticsData
            )
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                let result = PayPalVaultResult(tokenID: tokenID, approvalSessionID: sessionID)
                notifyVaultSuccess(for: result, completion: completion)
                return
            }
        }

        if hasCheckoutSuccess, let oid = orderID, let pid = payerID {
            analyticsService?.sendEvent(
                "paypal-web-payments:checkout:handle-return:succeeded",
                checkoutAnalyticsData: analyticsData
            )
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                let result = PayPalWebCheckoutResult(orderID: oid, payerID: pid)
                notifyCheckoutSuccess(for: result, completion: completion)
                return
            }
        }

        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:handle-return:failed",
            errorDescription: PayPalError.malformedResultError.errorDescription,
            checkoutAnalyticsData: analyticsData
        )
        if let completion = vaultAppSwitchCompletion {
            vaultAppSwitchCompletion = nil
            notifyVaultFailure(with: PayPalError.malformedResultError, completion: completion)
        } else if let completion = appSwitchCompletion {
            appSwitchCompletion = nil
            notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
        }
    }
    // swiftlint:enable function_body_length

    // MARK: - Private: Session-based Launch

    private func launchCheckout(
        session: ShopperSessionResult,
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        let completionOnce = makeCompletionOnce(completion)

        Task {
            await attemptSessionAppSwitchOrFallback(
                session: session,
                handlers: SessionAppSwitchHandlers(
                    completionOnce: completionOnce,
                    setCompletion: { [weak self] in self?.appSwitchCompletion = $0 },
                    eventPrefix: "paypal-web-payments:checkout"
                ),
                makeURL: { base, sessionID in
                    guard let tokenType = self.tokenType else { return nil }
                    return PayPalWebCheckoutURLBuilder(base: base).makeAppSwitchURL(
                        clientID: self.config.merchantID,
                        fundingSource: .paypal,
                        token: orderID,
                        tokenType: tokenType,
                        sessionID: sessionID
                    )
                },
                fallback: {
                    self.startWebCheckoutFlow(
                        session: session,
                        orderID: orderID,
                        fundingSource: .paypal,
                        completion: completionOnce
                    )
                }
            )
        }
    }

    private func launchVault(
        session: ShopperSessionResult,
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        let completionOnce = makeCompletionOnce(completion)

        Task {
            await attemptSessionAppSwitchOrFallback(
                session: session,
                handlers: SessionAppSwitchHandlers(
                    completionOnce: completionOnce,
                    setCompletion: { [weak self] in self?.vaultAppSwitchCompletion = $0 },
                    eventPrefix: "paypal-web-payments:vault-wo-purchase"
                ),
                makeURL: { base, sessionID in
                    guard let tokenType = self.tokenType else { return nil }
                    return PayPalWebCheckoutURLBuilder(base: base).makeAppSwitchURL(
                        clientID: self.config.merchantID,
                        fundingSource: .paypal,
                        token: setupTokenID,
                        tokenType: tokenType,
                        sessionID: sessionID
                    )
                },
                fallback: {
                    self.startVaultWebAuthFlow(session: session, setupTokenID: setupTokenID, completion: completionOnce)
                }
            )
        }
    }

    // MARK: - Private: App Switch (Session-based)

    private enum AppSwitchAttempt { case launched, fallback(String) }

    /// Bundles the flow-specific completion handling (`completionOnce`/`setCompletion`) and analytics
    /// `eventPrefix` used by `attemptSessionAppSwitchOrFallback`/`attemptSessionAppSwitch`, so those
    /// functions can stay within SwiftLint's parameter count limit.
    private struct SessionAppSwitchHandlers<T> {

        let completionOnce: (Result<T, CoreSDKError>) -> Void
        let setCompletion: (((Result<T, CoreSDKError>) -> Void)?) -> Void
        let eventPrefix: String
    }

    /// Resolves the session's redirect URL and session ID, attempts a session-based app switch, and
    /// invokes `fallback` whenever app-switch isn't eligible/resolvable or fails to launch. Shared by
    /// the checkout and vault-without-purchase flows via `makeURL` (flow-specific URL construction),
    /// `handlers` (completion/analytics passed through to `attemptSessionAppSwitch`), and `fallback`
    /// (the flow-specific web auth flow to start instead).
    private func attemptSessionAppSwitchOrFallback<T>(
        session: ShopperSessionResult,
        handlers: SessionAppSwitchHandlers<T>,
        makeURL: (_ base: String, _ sessionID: String) -> URL?,
        fallback: () -> Void
    ) async {
        if urlOpener.isPayPalAppInstalled(),
           session.appSwitchEligible,
           let base = session.redirectURL,
           let sessionID = session.shopperSessionConfig?.id,
           let url = makeURL(base, sessionID) {
            let result = await attemptSessionAppSwitch(url: url, handlers: handlers)
            switch result {
            case .launched:
                return
            case .fallback(let reason):
                analyticsService?.sendEvent("\(handlers.eventPrefix):fallback-to-web:\(reason)")
            }
        }
        fallback()
    }

    /// Attempts a session-based app switch to the PayPal app using the redirect URL from the session response.
    /// Shared by the checkout and vault-without-purchase flows: `handlers.setCompletion` stores/clears
    /// whichever completion property (`appSwitchCompletion` or `vaultAppSwitchCompletion`) belongs to the
    /// caller, and `handlers.eventPrefix` scopes the analytics events to that flow.
    private func attemptSessionAppSwitch<T>(
        url: URL,
        handlers: SessionAppSwitchHandlers<T>
    ) async -> AppSwitchAttempt {
        analyticsData?.appSwitchURL = url
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:app-switch:started",
            checkoutAnalyticsData: analyticsData
        )
        await MainActor.run {
            handlers.setCompletion(handlers.completionOnce)
        }
        let opened = await attemptAppSwitch(with: url)
        if opened {
            analyticsService?.sendEvent(
                "\(handlers.eventPrefix):app-switch:succeeded",
                checkoutAnalyticsData: analyticsData,
                withBackgroundProtection: true
            )
            return .launched
        } else {
            analyticsService?.sendEvent(
                "\(handlers.eventPrefix):app-switch:failed",
                errorDescription: "cannot_open_url",
                checkoutAnalyticsData: analyticsData
            )
            await MainActor.run {
                handlers.setCompletion(nil)
            }
            return .fallback("cannot_open_url")
        }
    }

    // MARK: - Private: Web Auth Flows

    private func startWebCheckoutFlow(
        session: ShopperSessionResult?,
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:auth-challenge-presentation:started",
            checkoutAnalyticsData: analyticsData
        )
        Task {
            do {
                _ = try await clientConfigAPI.updateClientConfig(
                    token: orderID,
                    fundingSource: fundingSource.rawValue
                )
            } catch {
                let sdkError = (error as? CoreSDKError) ?? PayPalError.webSessionError(error)
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:auth-challenge-presentation:failed",
                    errorDescription: sdkError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
                notifyCheckoutFailure(with: sdkError, completion: completion)
                return
            }

            guard let payPalCheckoutURL = makeCheckoutURL(
                session: session,
                orderID: orderID,
                fundingSource: fundingSource
            ),
                let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
            else {
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:auth-challenge-presentation:failed",
                    errorDescription: PayPalError.payPalURLError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            webAuthenticationSession.start(
                url: payPalCheckoutURLComponents,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    if didDisplay {
                        self?.analyticsService?.sendEvent(
                            "paypal-web-payments:checkout:auth-challenge-presentation:succeeded",
                            checkoutAnalyticsData: self?.analyticsData
                        )
                    }
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    self.handleCheckoutWebAuthCompletion(url: url, error: error, completion: completion)
                }
            )
        }
    }

    private func startVaultWebAuthFlow(
        session: ShopperSessionResult?,
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        Task {
            do {
                _ = try await clientConfigAPI.updateClientConfig(
                    token: setupTokenID,
                    fundingSource: PayPalWebCheckoutFundingSource.paypal.rawValue
                )
            } catch {
                let sdkError = (error as? CoreSDKError) ?? PayPalError.webSessionError(error)
                analyticsService?.sendEvent(
                    "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed",
                    errorDescription: sdkError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
                notifyVaultFailure(with: sdkError, completion: completion)
                return
            }

            guard let vaultCheckoutURL = makeVaultCheckoutURL(session: session, setupTokenID: setupTokenID) else {
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
                    self?.analyticsService?.sendEvent(event, checkoutAnalyticsData: self?.analyticsData)
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    self.handleVaultWebAuthCompletion(url: url, error: error, completion: completion)
                }
            )
        }
    }

    private func handleCheckoutWebAuthCompletion(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        defer { analyticsData = nil }
        if let error {
            let sdkError: CoreSDKError
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                sdkError = PayPalError.checkoutCanceledError
                analyticsService?.sendEvent(
                    "paypal:tokenize:browser-login:canceled",
                    errorDescription: sdkError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
            default:
                sdkError = PayPalError.webSessionError(error)
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:auth-challenge-presentation:failed",
                    errorDescription: sdkError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
            }

            sessionTask = nil
            notifyCheckoutFailure(with: sdkError, completion: completion)
        }

        if let url {
            if let opType = getQueryStringParameter(url: url.absoluteString, param: "opType"),
                opType == "cancel" {
                sessionTask = nil
                notifyCheckoutCancelWithError(
                    with: PayPalError.checkoutCanceledError, completion: completion
                )
            } else if let orderID = getQueryStringParameter(url: url.absoluteString, param: "token"),
                let payerID = getQueryStringParameter(url: url.absoluteString, param: "PayerID") {
                sessionTask = nil
                let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                notifyCheckoutSuccess(for: result, completion: completion)
            } else {
                sessionTask = nil
                notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
            }
        }
    }

    private func handleVaultWebAuthCompletion(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        defer { analyticsData = nil }
        if let error {
            let sdkError: CoreSDKError
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                sdkError = PayPalError.vaultCanceledError
                analyticsService?.sendEvent(
                    "paypal:tokenize:browser-login:canceled",
                    errorDescription: sdkError.errorDescription,
                    checkoutAnalyticsData: analyticsData
                )
            default:
                sdkError = PayPalError.webSessionError(error)
            }
            sessionTask = nil
            notifyVaultCancelWithError(with: sdkError, completion: completion)
        }

        if let url {
            if url.path.contains("cancel") {
                sessionTask = nil
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
            } else if
                let tokenID = getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                let approvalSessionID = getQueryStringParameter(
                    url: url.absoluteString, param: "approval_session_id"
                ),
                !tokenID.isEmpty, !approvalSessionID.isEmpty {
                sessionTask = nil
                let vaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
                notifyVaultSuccess(for: vaultResult, completion: completion)
            } else {
                sessionTask = nil
                notifyVaultFailure(with: PayPalError.payPalVaultResponseError, completion: completion)
            }
        }
    }

    /// Shared by the checkout and vault-without-purchase flows: `token`/`tokenType` identify what's being
    /// checked for app-switch eligibility (an order ID with `ExternalTokenKind.orderId` for checkout, a
    /// setup token ID with `ExternalTokenKind.vaultId` for vault), and `handlers` carries the flow-specific
    /// completion/analytics passed through to `attemptSessionAppSwitch`.
    private func attemptAppSwitchIfEligible<T>(
        token: String,
        tokenType: String,
        handlers: SessionAppSwitchHandlers<T>,
        paypalNativeAppInstalled: Bool = true
    ) async -> AppSwitchAttempt {
        do {
            let eligibility = try await patchCCOAPI.patchCCOWithAppSwitchEligibility(
                token: token,
                tokenType: tokenType,
                canSwitchToApp: paypalNativeAppInstalled
            )

            guard eligibility.appSwitchEligible == true,
                let urlString = eligibility.redirectURL
            else {
                return .fallback(eligibility.ineligibleReason ?? "ineligible")
            }
            guard let currentTokenType = self.tokenType,
                let url = PayPalWebCheckoutURLBuilder(base: urlString)
                    .makeAppSwitchURL(
                        clientID: config.merchantID,
                        fundingSource: .paypal,
                        token: token,
                        tokenType: currentTokenType,
                        sessionID: nil
                    )
            else {
                return .fallback("invalid_app_switch_url")
            }

            return await attemptSessionAppSwitch(url: url, handlers: handlers)
        } catch {
            analyticsService?.sendEvent("\(handlers.eventPrefix):app-switch-eligibility:error")
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

    private func checkoutFallbackURL(from session: ShopperSessionResult?, default defaultURL: URL) -> URL {
        guard
            let session,
            let checkoutFallbackURLString = session.checkoutFallbackURL,
            let url = URL(string: checkoutFallbackURLString)
        else {
            return defaultURL
        }
        return url
    }

    private func makeCheckoutURL(
        session: ShopperSessionResult?,
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource
    ) -> URL? {
        let baseURL = checkoutFallbackURL(from: session, default: config.environment.payPalBaseURL)
        var queryItems = [
            URLQueryItem(name: TokenType.orderID.tokenQueryParameterName, value: orderID),
            URLQueryItem(name: "fundingSource", value: fundingSource.rawValue),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]
        if let shopperSessionID = analyticsData?.shopperSessionID {
            queryItems.append(URLQueryItem(name: "shopperSessionId", value: shopperSessionID))
        }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems?.append(contentsOf: queryItems)
        return urlComponents?.url
    }

    private func makeVaultCheckoutURL(session: ShopperSessionResult?, setupTokenID: String) -> URL? {
        let baseURL = checkoutFallbackURL(from: session, default: config.environment.paypalVaultCheckoutURL)
        var vaultURLComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var queryItems = [
            URLQueryItem(name: TokenType.vaultID.tokenQueryParameterName, value: setupTokenID),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]
        if let sessionID = analyticsData?.shopperSessionID {
            queryItems.append(URLQueryItem(name: "shopperSessionId", value: sessionID))
        }
        vaultURLComponents?.queryItems?.append(contentsOf: queryItems)
        return vaultURLComponents?.url
    }

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

    // MARK: - Private: Notify Helpers

    private func notifyCheckoutSuccess(
        for result: PayPalWebCheckoutResult,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:succeeded", checkoutAnalyticsData: analyticsData)
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:failed",
            errorDescription: error.errorDescription,
            checkoutAnalyticsData: analyticsData
        )
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:canceled", checkoutAnalyticsData: analyticsData)
        completion(.failure(error))
    }

    private func notifyVaultSuccess(
        for result: PayPalVaultResult,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded", checkoutAnalyticsData: analyticsData)
        completion(.success(result))
    }

    private func notifyVaultFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:vault-wo-purchase:failed",
            errorDescription: error.errorDescription,
            checkoutAnalyticsData: analyticsData
        )
        completion(.failure(error))
    }

    private func notifyVaultCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:vault-wo-purchase:canceled",
            errorDescription: error.errorDescription,
            checkoutAnalyticsData: analyticsData
        )
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
