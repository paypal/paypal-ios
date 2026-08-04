import AuthenticationServices
import UIKit

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
    private let createShopperSessionAPI: CreateShopperSessionAPI
    
    private var activeShopperSession: ShopperSession
    
    /// Indicates whether the buyer progressed past the consent alert into the web auth modal.
    private var didApplicationBecomeActive = false

    private let systemLatency = SystemLatencyTracker()

    // MARK: - Initializer

    /// Initialize a `PayPalWebCheckoutClient` to process PayPal transactions.
    /// - Parameter config: The `CoreConfig` object.
    public init(config: CoreConfig) {
        self.config = config
        self.webAuthenticationSession = WebAuthenticationSession()
        self.clientConfigAPI = UpdateClientConfigAPI(coreConfig: config)
        self.createShopperSessionAPI = CreateShopperSessionAPI(coreConfig: config)
        self.activeShopperSession = PayPalShopperSession(config: config)
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    /// For internal use for testing/mocking purposes.
    init(
        config: CoreConfig,
        clientConfigAPI: UpdateClientConfigAPI,
        createShopperSessionAPI: CreateShopperSessionAPI,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        self.config = config
        self.webAuthenticationSession = webAuthenticationSession
        self.clientConfigAPI = clientConfigAPI
        self.createShopperSessionAPI = createShopperSessionAPI
        self.activeShopperSession = PayPalShopperSession(config: config)

        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func applicationDidBecomeActive() {
        didApplicationBecomeActive = true
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
        // clear latency measurements
        systemLatency.reset()
        
        // bind session to new context, this will cancel an existing session (if necessary)
        let sessionContext = ShopperSessionContext(
            sessionType: sessionType,
            userIdentity: userIdentity,
            urlConfig: urlConfig,
            userAction: userAction
        )
        activeShopperSession.bind(to: sessionContext)
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
        activeShopperSession.orderID = orderID
        systemLatency.begin(flow: .checkout)
        
        guard activeShopperSession.state == .initialized else {
            activeShopperSession.trackEvent(.sessionNotStarted)
            endSystemLatencyTracking(presentationType: .error)
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }
        
        Task {
            do {
                defer {
                    // TODO: rename reset() to clear()
                    activeShopperSession.reset()
                }
                let sessionDetails = try await activeShopperSession.sessionDetails
                activeShopperSession.trackEvent(.sessionCreated)
                activeShopperSession.trackEvent(.checkoutStarted)
                
                launchCheckout(session: sessionDetails, orderID: orderID, completion: completion)
            } catch {
                activeShopperSession.trackEvent(.sessionCreationFailed)
                let error = PayPalError.sessionNotCreatedError
                DispatchQueue.main.async { completion(.failure(error)) }
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
        activeShopperSession.setupTokenID = setupTokenID
        systemLatency.begin(flow: .vault)
        
        guard activeShopperSession.state == .initialized else {
            activeShopperSession.trackEvent(.sessionNotStarted)
            endSystemLatencyTracking(presentationType: .error)
            DispatchQueue.main.async {
                completion(.failure(PayPalError.sessionNotStartedError))
            }
            return
        }

        Task {
            do {
                defer {
                    // TODO: rename reset() to clear()
                    activeShopperSession.reset()
                }
                let sessionDetails = try await activeShopperSession.sessionDetails
                activeShopperSession.trackEvent(.sessionCreated)
                activeShopperSession.trackEvent(.checkoutStarted)

                launchVault(session: sessionDetails, setupTokenID: setupTokenID, completion: completion)
            } catch {
                activeShopperSession.trackEvent(.sessionCreationFailed)
                let error = PayPalError.sessionNotCreatedError
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - App Switch

    // swiftlint:disable function_body_length
    /// Routes a PayPal deep-link return URL back to the active checkout or vault flow.
    /// Call this from your `UIApplicationDelegate` or `Scene` delegate when a PayPal URL is received.
    public func handleReturnURL(_ url: URL) {
        defer {
            activeShopperSession.reset()
        }
        activeShopperSession.trackEvent(.handleReturnStarted)
        
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
            activeShopperSession.trackEvent(.handleReturnSucceeded)
            
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
                return
            }
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                activeShopperSession.trackEvent(.appSwitchCanceled)
                notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
                return
            }
            return
        }

        if hasVaultSuccess, let tokenID = vaultTokenID, let sessionID = vaultSessionID {
            activeShopperSession.trackEvent(.handleReturnSucceeded)
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                let result = PayPalVaultResult(tokenID: tokenID, approvalSessionID: sessionID)
                notifyVaultSuccess(for: result, completion: completion)
                return
            }
        }

        if hasCheckoutSuccess, let oid = orderID, let pid = payerID {
            activeShopperSession.trackEvent(.handleReturnSucceeded)
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                let result = PayPalWebCheckoutResult(orderID: oid, payerID: pid)
                notifyCheckoutSuccess(for: result, completion: completion)
                return
            }
        }
        
        activeShopperSession.trackEvent(.handleReturnFailed)
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
                    guard let tokenType = self.activeShopperSession.tokenType else { return nil }
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
                    eventPrefix: "paypal-web-payments:checkout"
                ),
                makeURL: { base, sessionID in
                    guard let tokenType = self.activeShopperSession.tokenType else { return nil }
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
                let event: PayPalAnalyticsEvent =
                    .fallbackToWeb(eventPrefix: handlers.eventPrefix, reason: reason)
                activeShopperSession.trackEvent(event)
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
        activeShopperSession.appSwitchURL = url
        activeShopperSession.trackEvent(.appSwitchStarted)
        
        await MainActor.run {
            handlers.setCompletion(handlers.completionOnce)
        }
        let opened = await attemptAppSwitch(with: url)
        if opened {
            activeShopperSession.trackEvent(.appSwitchSucceeded, withBackgroundProtection: true)
            endSystemLatencyTracking(presentationType: .appSwitch)
            return .launched
        } else {
            let event: PayPalAnalyticsEvent =
                .appSwitchFailed(eventPrefix: handlers.eventPrefix, errorDescription: "cannot_open_url")
            activeShopperSession.trackEvent(event)
            await MainActor.run {
                handlers.setCompletion(nil)
            }
            return .fallback("cannot_open_url")
        }
    }

    // MARK: - Private: System Latency

    private func endSystemLatencyTracking(presentationType: SystemLatencyTracker.PresentationType) {
        // TODO: consider migrating system latency into shopper session class
//        systemLatency.send(
//            presentationType: presentationType,
//            using: analyticsService,
//            checkoutAnalyticsData: analyticsData
//        )
    }

    // MARK: - Private: Web Auth Flows

    private func startWebCheckoutFlow(
        session: ShopperSessionResult,
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.authChallengePresentationStarted)
        Task {
            do {
                _ = try await clientConfigAPI.updateClientConfig(
                    token: orderID,
                    fundingSource: fundingSource.rawValue
                )
            } catch {
                let sdkError = (error as? CoreSDKError) ?? PayPalError.webSessionError(error)
                let event: PayPalAnalyticsEvent =
                    .authChallengePresentationFailed(errorDescription: sdkError.errorDescription)
                activeShopperSession.trackEvent(event)
                endSystemLatencyTracking(presentationType: .error)
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
                let errorDescription = PayPalError.payPalURLError.errorDescription
                let event: PayPalAnalyticsEvent =
                    .authChallengePresentationFailed(errorDescription: errorDescription)
                activeShopperSession.trackEvent(event)
                endSystemLatencyTracking(presentationType: .error)
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            didApplicationBecomeActive = false
            endSystemLatencyTracking(presentationType: .browser)
            webAuthenticationSession.start(
                url: payPalCheckoutURLComponents,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    if didDisplay {
                        self?.activeShopperSession.trackEvent(.authChallengePresentationSucceeded)
                    }
                },
                sessionDidCancel: { [weak self] in
                    guard let self else { return }
                    self.handleCheckoutWebAuthCancel(completion: completion)
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    self.handleCheckoutWebAuthCompletion(url: url, error: error, completion: completion)
                }
            )
        }
    }

    private func startVaultWebAuthFlow(
        session: ShopperSessionResult,
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
                activeShopperSession.trackEvent(.authChallengePresentationFailed(errorDescription: sdkError.errorDescription))
                endSystemLatencyTracking(presentationType: .error)
                notifyVaultFailure(with: sdkError, completion: completion)
                return
            }

            guard let vaultCheckoutURL = makeVaultCheckoutURL(session: session, setupTokenID: setupTokenID) else {
                let errorDescription = PayPalError.payPalURLError.errorDescription
                activeShopperSession.trackEvent(.authChallengePresentationFailed(errorDescription: errorDescription))
                endSystemLatencyTracking(presentationType: .error)
                notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }
            didApplicationBecomeActive = false
            endSystemLatencyTracking(presentationType: .browser)
            webAuthenticationSession.start(
                url: vaultCheckoutURL,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    let event: PayPalAnalyticsEvent = didDisplay
                        ? .authChallengePresentationSucceeded
                        : .authChallengePresentationFailed(errorDescription: nil)
                    self?.activeShopperSession.trackEvent(event)
                },
                sessionDidCancel: { [weak self] in
                    guard let self else { return }
                    self.handleVaultWebAuthCancel(completion: completion)
                },
                sessionDidComplete: { [weak self] url, error in
                    guard let self else { return }
                    self.handleVaultWebAuthCompletion(url: url, error: error, completion: completion)
                }
            )
        }
    }

    private func handleCheckoutWebAuthCancel(
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        defer {
            activeShopperSession.reset()
        }
        let sdkError = PayPalError.checkoutCanceledError
        sendBrowserLoginCancelEvent(errorDescription: sdkError.errorDescription)
        notifyCheckoutFailure(with: sdkError, completion: completion)
    }

    private func handleCheckoutWebAuthCompletion(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        defer {
            activeShopperSession.reset()
        }
        if let error {
            let sdkError = PayPalError.webSessionError(error)
            let errorDescription = sdkError.errorDescription
            activeShopperSession.trackEvent(.authChallengePresentationFailed(errorDescription: errorDescription))
            
            notifyCheckoutFailure(with: sdkError, completion: completion)
        }

        if let url {
            if let opType = getQueryStringParameter(url: url.absoluteString, param: "opType"),
                opType == "cancel" {
                notifyCheckoutCancelWithError(
                    with: PayPalError.checkoutCanceledError, completion: completion
                )
            } else if let orderID = getQueryStringParameter(url: url.absoluteString, param: "token"),
                let payerID = getQueryStringParameter(url: url.absoluteString, param: "PayerID") {
                let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
                notifyCheckoutSuccess(for: result, completion: completion)
            } else {
                notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
            }
            activeShopperSession.reset()
        }
    }

    private func handleVaultWebAuthCancel(
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        defer {
            activeShopperSession.reset()
        }
        let sdkError = PayPalError.vaultCanceledError
        sendBrowserLoginCancelEvent(errorDescription: sdkError.errorDescription)
        notifyVaultCancelWithError(with: sdkError, completion: completion)
    }

    private func handleVaultWebAuthCompletion(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        defer {
            activeShopperSession.reset()
        }
        if let error {
            let sdkError = PayPalError.webSessionError(error)
            notifyVaultFailure(with: sdkError, completion: completion)
        }

        if let url {
            if url.path.contains("cancel") {
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
            } else if
                let tokenID = getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
                let approvalSessionID = getQueryStringParameter(
                    url: url.absoluteString, param: "approval_session_id"
                ),
                !tokenID.isEmpty, !approvalSessionID.isEmpty {
                let vaultResult = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
                notifyVaultSuccess(for: vaultResult, completion: completion)
            } else {
                notifyVaultFailure(with: PayPalError.payPalVaultResponseError, completion: completion)
            }
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

    private func checkoutFallbackURL(from session: ShopperSessionResult, default defaultURL: URL) -> URL {
        guard
            let checkoutFallbackURLString = session.checkoutFallbackURL,
            let url = URL(string: checkoutFallbackURLString)
        else {
            return defaultURL
        }
        return url
    }

    private func makeCheckoutURL(
        session: ShopperSessionResult,
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource
    ) -> URL? {
        let baseURL = checkoutFallbackURL(from: session, default: config.environment.payPalBaseURL)
        var queryItems = [
            URLQueryItem(name: TokenType.orderID.tokenQueryParameterName, value: orderID),
            URLQueryItem(name: "fundingSource", value: fundingSource.rawValue),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]
        if let shopperSessionID = activeShopperSession.shopperSessionID {
            queryItems.append(URLQueryItem(name: "shopperSessionId", value: shopperSessionID))
        }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems?.append(contentsOf: queryItems)
        return urlComponents?.url
    }

    private func makeVaultCheckoutURL(session: ShopperSessionResult, setupTokenID: String) -> URL? {
        let baseURL = checkoutFallbackURL(from: session, default: config.environment.paypalVaultCheckoutURL)
        var vaultURLComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var queryItems = [
            URLQueryItem(name: TokenType.vaultID.tokenQueryParameterName, value: setupTokenID),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]
        if let sessionID = activeShopperSession.shopperSessionID {
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

    private func sendBrowserLoginCancelEvent(errorDescription: String?) {
        let event: PayPalAnalyticsEvent = didApplicationBecomeActive
            ? .browserLoginCanceled(errorDescription: errorDescription)
            : .browserLoginAlertCanceled(errorDescription: errorDescription)
        activeShopperSession.trackEvent(event)
    }

    // MARK: - Private: Notify Helpers

    private func notifyCheckoutSuccess(
        for result: PayPalWebCheckoutResult,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutSucceeded)
        completion(.success(result))
    }

    private func notifyCheckoutFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutFailed(errorDescription: nil))
        completion(.failure(error))
    }

    private func notifyCheckoutCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutCanceled)
        completion(.failure(error))
    }

    private func notifyVaultSuccess(
        for result: PayPalVaultResult,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutSucceeded)
        completion(.success(result))
    }

    private func notifyVaultFailure(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutFailed(errorDescription: error.errorDescription))
        completion(.failure(error))
    }

    private func notifyVaultCancelWithError(
        with error: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        activeShopperSession.trackEvent(.checkoutCanceled)
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
