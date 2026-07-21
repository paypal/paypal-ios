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
    private var pendingSystemLatency: PendingSystemLatency?
    private var didSendSystemLatency = false

    /// When set, unit tests can supply analytics services backed by mock tracking APIs.
    var analyticsServiceProviderFactory: ((CoreConfig, String?, String?) -> AnalyticsService) = { config, orderID, setupToken in

        if let orderID {
            return AnalyticsService(coreConfig: config, orderID: orderID)
        }
        if let setupToken {
            return AnalyticsService(coreConfig: config, setupToken: setupToken)
        }
        return AnalyticsService(coreConfig: config)
    }

    /// Holds the in-flight or completed Shopper Session fetch.
    /// Set by `createPayPalSession()`. Cleared automatically on checkout success, cancellation, or error.
    private var sessionTask: Task<ShopperSessionResult, Error>?

    // MARK: - Analytics State

    private var sessionCreationStartTime: Int64?

    private var isCachedSession: Bool?

    private var shopperSessionID: String?

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
    ///   - userIdentity: Optional buyer identity. Defaults to `nil`.
    ///   - urlConfig: Return and cancel deep-link URLs registered with PayPal.
    ///   - userAction: The buyer action intent. Defaults to `.continue`.
    public func createPayPalSession(
        userIdentity: PayPalUserIdentity? = nil,
        urlConfig: PayPalURLConfig,
        userAction: PayPalUserAction = .continue
    ) {
        sessionTask?.cancel()

        sessionCreationStartTime = HTTPResponseTiming.epochMilliseconds()
        isCachedSession = userIdentity?.existingPayPalSessionID != nil
        analyticsService?.sendEvent("paypal-web-payments:checkout:ssid-session:started")

        sessionTask = Task {
            try await createShopperSessionAPI.createShopperSessionWithAppSwitchEligibility(
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
                shopperSessionId: shopperSessionID
            )
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = makeAnalyticsService(orderID: orderID)
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.checkout)

        Task {
            do {
                defer {
                    sessionCreationStartTime = nil
                    isCachedSession = nil
                    sessionTask = nil
                }

                let session = try await task.value
                shopperSessionID = session.shopperSessionConfig?.id
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:succeeded",
                    isCachedSession: isCachedSession,
                    isVaultRequest: false,
                    shopperSessionId: shopperSessionID,
                    startTime: sessionCreationStartTime
                )
                analyticsService?.sendEvent("paypal-web-payments:checkout:started", shopperSessionId: shopperSessionID)
                launchCheckout(session: session, orderID: orderID, completion: completion)
            } catch {
                sessionTask = nil
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:failed",
                    errorDescription: error.localizedDescription,
                    shopperSessionId: shopperSessionID
                )
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                await fallBackToPatchCCOOrWeb(orderID: orderID, completion: completion)
            }
        }
    }

    /// Initiates checkout by creating an order via the merchant-provided callback, then launching checkout.
    ///
    /// `createPayPalSession()` **must** be called before this method.
    ///
    /// - Parameters:
    ///   - createOrder: Async closure that creates an order and returns its ID.
    ///   - completion: Completion invoked on the main thread with the checkout result.
    public func start(
        createOrder: @escaping () async throws -> String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        guard let task = sessionTask else {
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.checkout)

        Task {
            do {
                let orderID = try await measureCreateOrder(createOrder)
                analyticsService = makeAnalyticsService(orderID: orderID)

                let session = try await task.value
                sessionTask = nil
                shopperSessionID = session.shopperSessionConfig?.id
                analyticsService?.sendEvent("paypal-web-payments:checkout:started", shopperSessionId: shopperSessionID)
                launchCheckout(session: session, orderID: orderID, completion: completion)
            } catch {
                sessionTask = nil
                let sdkError = sdkError(from: error, fallback: "Checkout failed.")
                analyticsService = makeAnalyticsService()
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:failed",
                    errorDescription: sdkError.errorDescription,
                    shopperSessionId: shopperSessionID
                )
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        }
    }

    /// Initiates checkout by creating an order via the merchant-provided callback, then launching checkout.
    public func start(createOrder: @escaping () async throws -> String) async throws -> PayPalWebCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(createOrder: createOrder) { result in
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Falls back to the legacy PatchCCO app-switch-eligibility check (and, if that's not eligible or
    /// fails to launch, to the web auth flow) when the Shopper Session fetch itself fails, so a session
    /// fetch error doesn't fail checkout outright if app-switch or web checkout can still recover it.
    private func fallBackToPatchCCOOrWeb(
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        guard appInstalled else {
            startWebCheckoutFlow(orderID: orderID, fundingSource: .paypal, completion: completionOnce)
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
            startWebCheckoutFlow(orderID: orderID, fundingSource: .paypal, completion: completionOnce)
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
                shopperSessionId: shopperSessionID
            )
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        analyticsService = makeAnalyticsService(setupToken: setupTokenID)
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.vault)

        Task {
            do {
                defer {
                    sessionCreationStartTime = nil
                    isCachedSession = nil
                    sessionTask = nil
                }

                let session = try await task.value
                shopperSessionID = session.shopperSessionConfig?.id
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:succeeded",
                    isCachedSession: isCachedSession,
                    isVaultRequest: true,
                    shopperSessionId: shopperSessionID,
                    startTime: sessionCreationStartTime
                )
                analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started", shopperSessionId: shopperSessionID)
                launchVault(session: session, setupTokenID: setupTokenID, completion: completion)
            } catch {
                sessionTask = nil
                analyticsService?.sendEvent(
                    "paypal-web-payments:create-paypal-session:failed",
                    errorDescription: error.localizedDescription,
                    shopperSessionId: shopperSessionID
                )
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                await fallBackToPatchCCOOrWebForVault(setupTokenID: setupTokenID, completion: completion)
            }
        }
    }

    /// Initiates vault by creating a setup token via the merchant-provided callback, then launching vault.
    ///
    /// `createPayPalSession()` **must** be called before this method.
    ///
    /// - Parameters:
    ///   - createSetupToken: Async closure that creates a setup token and returns its ID.
    ///   - completion: Completion invoked on the main thread with the vault result.
    public func vault(
        createSetupToken: @escaping () async throws -> String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        guard let task = sessionTask else {
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.vault)

        Task {
            do {
                let setupTokenID = try await measureCreateSession(createSetupToken)
                analyticsService = makeAnalyticsService(setupToken: setupTokenID)

                let session = try await task.value
                sessionTask = nil
                shopperSessionID = session.shopperSessionConfig?.id
                analyticsService?.sendEvent(
                    "paypal-web-payments:vault-wo-purchase:started",
                    shopperSessionId: shopperSessionID
                )
                startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completion)
            } catch {
                sessionTask = nil
                let sdkError = sdkError(from: error, fallback: "Vault failed.")
                analyticsService = makeAnalyticsService()
                analyticsService?.sendEvent(
                    "paypal-web-payments:vault-wo-purchase:failed",
                    errorDescription: sdkError.errorDescription,
                    shopperSessionId: shopperSessionID
                )
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        }
    }

    /// Initiates vault by creating a setup token via the merchant-provided callback, then launching vault.
    public func vault(createSetupToken: @escaping () async throws -> String) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(createSetupToken: createSetupToken) { result in
                switch result {
                case .success(let value): continuation.resume(returning: value)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Falls back to the legacy PatchCCO app-switch-eligibility check (and, if that's not eligible or
    /// fails to launch, to the vault web auth flow) when the Shopper Session fetch itself fails, so a
    /// session fetch error doesn't fail vault outright if app-switch or web vault can still recover it.
    /// Mirrors `fallBackToPatchCCOOrWeb`, but checks eligibility for `setupTokenID` under
    /// `ExternalTokenKind.vaultId` (per Android's equivalent implementation) instead of an order ID.
    private func fallBackToPatchCCOOrWebForVault(
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        let completionOnce = makeCompletionOnce(completion)
        let appInstalled = urlOpener.isPayPalAppInstalled()

        guard appInstalled else {
            startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completionOnce)
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
            startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completionOnce)
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
        analyticsService = makeAnalyticsService(orderID: request.orderID)
        analyticsService?.sendEvent("paypal-web-payments:checkout:started")
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.checkout)

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
        analyticsService = makeAnalyticsService(setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.vault)
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

    // swiftlint:disable function_body_length
    /// Routes a PayPal deep-link return URL back to the active checkout or vault flow.
    /// Call this from your `UIApplicationDelegate` or `Scene` delegate when a PayPal URL is received.
    public func handleReturnURL(_ url: URL) {
        defer {
            shopperSessionID = nil
            sessionTask = nil
        }

        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:handle-return:started",
            shopperSessionId: shopperSessionID
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
                shopperSessionId: shopperSessionID
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
                    shopperSessionId: shopperSessionID
                )
                notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
                return
            }
            return
        }

        if hasVaultSuccess, let tokenID = vaultTokenID, let sessionID = vaultSessionID {
            analyticsService?.sendEvent(
                "paypal-web-payments:checkout:handle-return:succeeded",
                shopperSessionId: shopperSessionID
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
                shopperSessionId: shopperSessionID
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
            shopperSessionId: shopperSessionID
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
                    PayPalWebCheckoutURLBuilder(base: base).checkoutAppSwitchURL(
                        clientID: self.config.merchantID,
                        fundingSource: .paypal,
                        orderID: orderID,
                        sessionID: sessionID
                    )
                },
                fallback: {
                    self.startWebCheckoutFlow(orderID: orderID, fundingSource: .paypal, completion: completionOnce)
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
                    PayPalWebCheckoutURLBuilder(base: base).vaultAppSwitchURL(
                        merchantID: self.config.merchantID,
                        fundingSource: .paypal,
                        sessionID: sessionID,
                        setupTokenID: setupTokenID
                    )
                },
                fallback: {
                    self.startVaultWebAuthFlow(setupTokenID: setupTokenID, completion: completionOnce)
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
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:app-switch:started",
            appSwitchURL: url,
            shopperSessionId: shopperSessionID
        )
        await MainActor.run {
            handlers.setCompletion(handlers.completionOnce)
        }
        await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.appSwitch)
        let opened = await attemptAppSwitch(with: url)
        if opened {
            analyticsService?.sendEvent(
                "\(handlers.eventPrefix):app-switch:succeeded",
                withBackgroundProtection: true,
                appSwitchURL: url,
                shopperSessionId: shopperSessionID,
            )
            return .launched
        } else {
            analyticsService?.sendEvent(
                "\(handlers.eventPrefix):app-switch:failed",
                errorDescription: "cannot_open_url",
                shopperSessionId: shopperSessionID
            )
            await MainActor.run {
                handlers.setCompletion(nil)
            }
            return .fallback("cannot_open_url")
        }
    }

    // MARK: - Private: Web Auth Flows

    // swiftlint:disable:next function_body_length
    private func startWebCheckoutFlow(
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:auth-challenge-presentation:started",
            shopperSessionId: shopperSessionID
        )
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
                analyticsService?.sendEvent(
                    "paypal-web-payments:checkout:auth-challenge-presentation:failed",
                    errorDescription: PayPalError.payPalURLError.errorDescription,
                    shopperSessionId: shopperSessionID
                )
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.browser)
            webAuthenticationSession.start(
                url: payPalCheckoutURLComponents,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    if didDisplay {
                        self?.analyticsService?.sendEvent(
                            "paypal-web-payments:checkout:auth-challenge-presentation:succeeded",
                            shopperSessionId: self?.shopperSessionID
                        )
                    }
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    defer { self.shopperSessionID = nil }
                    if let error {
                        let sdkError: CoreSDKError
                        switch error {
                        case ASWebAuthenticationSessionError.canceledLogin:
                            sdkError = PayPalError.checkoutCanceledError
                        default:
                            sdkError = PayPalError.webSessionError(error)
                        }
                        self.analyticsService?.sendEvent(
                            "paypal-web-payments:checkout:auth-challenge-presentation:failed",
                            errorDescription: sdkError.errorDescription,
                            shopperSessionId: self.shopperSessionID
                        )
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
            Task {
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            }
            return
        }

        Task {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.browser)
            webAuthenticationSession.start(
                url: vaultCheckoutURL,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    let event = didDisplay
                        ? "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
                        : "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed"
                    self?.analyticsService?.sendEvent(event, shopperSessionId: self?.shopperSessionID)
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    defer { self.shopperSessionID = nil }
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
                let urlString = eligibility.redirectURL,
                let url = URL(string: urlString)
            else {
                return .fallback(eligibility.ineligibleReason ?? "ineligible")
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

    private func beginSystemLatencyTracking(flow: String) {
        pendingSystemLatency = PendingSystemLatency(
            startTime: HTTPResponseTiming.epochMilliseconds(),
            flow: flow
        )
        didSendSystemLatency = false
    }

    private func sendSystemLatencyEventIfNeeded(presentationType: String) async {
        guard !didSendSystemLatency, let pendingSystemLatency else { return }

        didSendSystemLatency = true
        await analyticsService?.sendEventAndAwaitDelivery(
            PayPalWebAnalytics.systemLatency,
            startTime: pendingSystemLatency.startTime,
            endTime: HTTPResponseTiming.epochMilliseconds(),
            presentationType: presentationType,
            flow: pendingSystemLatency.flow
        )
    }

    private func measureCreateOrder(
        _ createOrder: @escaping () async throws -> String
    ) async throws -> String {
        let startTime = HTTPResponseTiming.epochMilliseconds()
        do {
            let orderID = try await createOrder()
            await sendAPIRequestLatencyEvent(
                startTime: startTime,
                endTime: HTTPResponseTiming.epochMilliseconds(),
                endpoint: PayPalWebAnalytics.createOrderEndpoint,
                orderID: orderID
            )
            return orderID
        } catch {
            await sendAPIRequestLatencyEvent(
                startTime: startTime,
                endTime: HTTPResponseTiming.epochMilliseconds(),
                endpoint: PayPalWebAnalytics.createOrderEndpoint,
                orderID: nil
            )
            throw error
        }
    }

    private func measureCreateSession(
        _ createSetupToken: @escaping () async throws -> String
    ) async throws -> String {
        let startTime = HTTPResponseTiming.epochMilliseconds()
        do {
            let setupTokenID = try await createSetupToken()
            await sendAPIRequestLatencyEvent(
                startTime: startTime,
                endTime: HTTPResponseTiming.epochMilliseconds(),
                endpoint: PayPalWebAnalytics.createSessionEndpoint,
                setupTokenID: setupTokenID
            )
            return setupTokenID
        } catch {
            await sendAPIRequestLatencyEvent(
                startTime: startTime,
                endTime: HTTPResponseTiming.epochMilliseconds(),
                endpoint: PayPalWebAnalytics.createSessionEndpoint,
                setupTokenID: nil
            )
            throw error
        }
    }

    private func sendAPIRequestLatencyEvent(
        startTime: Int64,
        endTime: Int64,
        endpoint: String,
        orderID: String? = nil,
        setupTokenID: String? = nil
    ) async {
        let service = makeAnalyticsService(orderID: orderID, setupToken: setupTokenID)

        await service.sendEventAndAwaitDelivery(
            PayPalWebAnalytics.apiRequestLatency,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint
        )
    }

    // TODO: Consider extracting an "AnalyticsFactory" type that can be injected into the constructor of PayPalWebCheckoutClient or go further and determine if there's another way to provide orderID and setupToken as Analytics metadata parameters
    private func makeAnalyticsService(orderID: String? = nil, setupToken: String? = nil) -> AnalyticsService {
        return analyticsServiceProviderFactory(config, orderID, setupToken)
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
        analyticsService?.sendEvent("paypal-web-payments:checkout:succeeded", shopperSessionId: shopperSessionID)
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:checkout:failed",
            errorDescription: error.errorDescription,
            shopperSessionId: shopperSessionID
        )
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:checkout:canceled", shopperSessionId: shopperSessionID)
        completion(.failure(error))
    }

    private func notifyVaultSuccess(
        for result: PayPalVaultResult,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:succeeded", shopperSessionId: shopperSessionID)
        completion(.success(result))
    }

    private func notifyVaultFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent(
            "paypal-web-payments:vault-wo-purchase:failed",
            errorDescription: error.errorDescription,
            shopperSessionId: shopperSessionID
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
            shopperSessionId: shopperSessionID
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
