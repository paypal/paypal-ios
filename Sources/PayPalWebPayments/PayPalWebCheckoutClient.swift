import AuthenticationServices
import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

// swiftlint: disable type_body_length file_length
public class PayPalWebCheckoutClient: NSObject {

    static let serialDispatchQueue =
        DispatchQueue(label: "com.paypal.ios.PayPalWebCheckoutClient.serialDispatchQueue")

    let config: CoreConfig

    var appSwitchCompletion: ((Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void)?
    var vaultAppSwitchCompletion: ((Result<PayPalVaultResult, CoreSDKError>) -> Void)?
    var application: URLOpener = UIApplication.shared

    private let clientConfigAPI: UpdateClientConfigAPI
    private let webAuthenticationSession: WebAuthenticationSession
    private let createShopperSessionAPI: CreateShopperSessionAPIProtocol
    private let patchCCOAPI: PatchCCOAPIProtocol
    private var analyticsService: AnalyticsService?
    private var pendingSystemLatency: PendingSystemLatency?
    private var didSendSystemLatency = false

    /// Exposed for unit tests to verify analytics payloads.
    var analyticsServiceForTesting: AnalyticsService? { analyticsService }

    /// When set, unit tests can supply analytics services backed by mock tracking APIs.
    var unitTestAnalyticsServiceProvider: ((CoreConfig, String?, String?) -> AnalyticsService)?

    /// Initialize a PayPalWebCheckoutClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.webAuthenticationSession = WebAuthenticationSession()
        self.clientConfigAPI = UpdateClientConfigAPI(coreConfig: config)
        self.createShopperSessionAPI = CreateShopperSessionAPI(coreConfig: config)
        self.patchCCOAPI = PatchCCOWithAppSwitchEligibility(coreConfig: config)
    }

    /// For internal use for testing/mocking purpose
    init(
        config: CoreConfig,
        clientConfigAPI: UpdateClientConfigAPI,
        createShopperSessionAPI: CreateShopperSessionAPIProtocol,
        patchCCOAPI: PatchCCOAPIProtocol,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        self.config = config
        self.webAuthenticationSession = webAuthenticationSession
        self.clientConfigAPI = clientConfigAPI
        self.createShopperSessionAPI = createShopperSessionAPI
        self.patchCCOAPI = patchCCOAPI
    }

    /// Launch the PayPal checkout flow.
    public func start(
        request: PayPalWebCheckoutRequest,
        createOrder: @escaping () async throws -> String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        let completionOnce = makeCompletionOnce(completion)
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.checkout)

        Task {
            if request.userAction == .setupNow {
                analyticsService = makeAnalyticsService()
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyCheckoutFailure(with: PayPalError.invalidUserActionError, completion: completionOnce)
                return
            }

            do {
                async let sessionTask = createShopperSessionAPI.createShopperSessionForCheckout(
                    request: request,
                    paypalAppInstalled: application.isPayPalAppInstalled(),
                    venmoAppInstalled: application.isVenmoAppInstalled()
                )
                async let orderIDTask = measureCreateOrder(createOrder)

                let orderID = try await orderIDTask
                analyticsService = makeAnalyticsService(orderID: orderID)
                analyticsService?.sendEvent("paypal-web-payments:checkout:started")

                do {
                    let session = try await sessionTask
                    if session.paymentMethodConfig?.ssidRouting == true {
                        await routeSSIDCheckout(
                            session: session,
                            orderID: orderID,
                            completion: completionOnce
                        )
                    } else {
                        await fallbackPatchCCO(orderID: orderID, completion: completionOnce)
                    }
                } catch {
                    // Checkout-only: patchCCO is the silent fallback when SSID session creation fails.
                    await fallbackPatchCCO(orderID: orderID, completion: completionOnce)
                }
            } catch {
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyCheckoutFailure(with: mapError(error), completion: completionOnce)
            }
        }
    }

    public func start(
        request: PayPalWebCheckoutRequest,
        createOrder: @escaping () async throws -> String
    ) async throws -> PayPalWebCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(request: request, createOrder: createOrder) { result in
                switch result {
                case .success(let checkoutResult):
                    continuation.resume(returning: checkoutResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Launch the PayPal vault flow.
    ///
    /// Vault does not use patchCCO (checkout-only). When SSID session creation fails or
    /// `ssidRouting` is false, the SDK silently falls back to the legacy web vault flow.
    /// Merchants only receive failures from `createSetupToken` or the vault UI itself.
    public func vault(
        _ vaultRequest: PayPalVaultRequest,
        createSetupToken: @escaping () async throws -> String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        beginSystemLatencyTracking(flow: PayPalWebAnalytics.Flow.vault)

        Task {
            do {
                async let sessionTask = createShopperSessionAPI.createShopperSessionForVault(
                    request: vaultRequest,
                    paypalAppInstalled: application.isPayPalAppInstalled(),
                    venmoAppInstalled: application.isVenmoAppInstalled()
                )
                async let setupTokenTask = measureCreateSession(createSetupToken)

                let setupTokenID = try await setupTokenTask
                analyticsService = makeAnalyticsService(setupToken: setupTokenID)
                analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:started")

                do {
                    let session = try await sessionTask
                    if session.paymentMethodConfig?.ssidRouting == true {
                        await routeSSIDVault(
                            session: session,
                            setupTokenID: setupTokenID,
                            completion: completion
                        )
                    } else {
                        await launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
                    }
                } catch {
                    await launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
                }
            } catch {
                analyticsService = analyticsService ?? makeAnalyticsService()
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyVaultFailure(with: mapError(error), completion: completion)
            }
        }
    }

    public func vault(
        _ vaultRequest: PayPalVaultRequest,
        createSetupToken: @escaping () async throws -> String
    ) async throws -> PayPalVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(vaultRequest, createSetupToken: createSetupToken) { result in
                switch result {
                case .success(let vaultResult):
                    continuation.resume(returning: vaultResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - App Switch Method

    public func handleReturnURL(_ url: URL) {
        func queryValue(_ name: String) -> String? {
            getQueryStringParameter(url: url.absoluteString, param: name)
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
                notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
                return
            }
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
                return
            }
            return
        }

        if hasVaultSuccess, let tokenID = vaultTokenID, let sessionID = vaultSessionID {
            if let completion = vaultAppSwitchCompletion {
                vaultAppSwitchCompletion = nil
                let result = PayPalVaultResult(tokenID: tokenID, approvalSessionID: sessionID)
                notifyVaultSuccess(for: result, completion: completion)
                return
            }
        }

        if hasCheckoutSuccess, let oid = orderID, let pid = payerID {
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                let result = PayPalWebCheckoutResult(orderID: oid, payerID: pid)
                notifyCheckoutSuccess(for: result, completion: completion)
                return
            }
        }

        if let completion = vaultAppSwitchCompletion {
            vaultAppSwitchCompletion = nil
            notifyVaultFailure(with: PayPalError.malformedResultError, completion: completion)
        } else if let completion = appSwitchCompletion {
            appSwitchCompletion = nil
            notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
        }
    }

    // MARK: - Private Methods

    private func routeSSIDCheckout(
        session: ShopperSessionWithAppSwitchEligibility,
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        let eligible = session.paymentMethodConfig?.appSwitchEligible == true
            && application.isPayPalAppInstalled()

        if eligible,
            let base = session.checkoutUrls?.appCheckout,
            let sessionID = session.sessionId {
            let urlString = PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                base: base,
                orderID: orderID,
                clientID: config.clientID,
                sessionID: sessionID
            )
            guard let url = URL(string: urlString) else {
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            await MainActor.run { appSwitchCompletion = completion }

            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.appSwitch)
            let opened = await openURL(url)
            if opened {
                analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:succeeded")
            } else {
                analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:failed")
                await MainActor.run { appSwitchCompletion = nil }
                if let webBase = session.checkoutUrls?.webCheckoutWeb,
                    let sessionID = session.sessionId {
                    await launchCheckoutBrowser(
                        base: webBase,
                        orderID: orderID,
                        sessionID: sessionID,
                        completion: completion
                    )
                } else {
                    await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                    notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                }
            }
        } else if let webBase = session.checkoutUrls?.webCheckoutWeb,
            let sessionID = session.sessionId {
            await launchCheckoutBrowser(
                base: webBase,
                orderID: orderID,
                sessionID: sessionID,
                completion: completion
            )
        } else {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
            notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
        }
    }

    private func routeSSIDVault(
        session: ShopperSessionWithAppSwitchEligibility,
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        let eligible = session.paymentMethodConfig?.appSwitchEligible == true
            && application.isPayPalAppInstalled()

        if eligible,
            let base = session.checkoutUrls?.appApprovalUrl,
            let sessionID = session.sessionId {
            let urlString = PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
                base: base,
                setupTokenID: setupTokenID,
                clientID: config.clientID,
                sessionID: sessionID
            )
            guard let url = URL(string: urlString) else {
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
                notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            await MainActor.run { vaultAppSwitchCompletion = completion }

            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.appSwitch)
            let opened = await openURL(url)
            if !opened,
                let webBase = session.checkoutUrls?.webApprovalUrl,
                let sessionID = session.sessionId {
                await MainActor.run { vaultAppSwitchCompletion = nil }
                await launchVaultBrowser(
                    base: webBase,
                    setupTokenID: setupTokenID,
                    sessionID: sessionID,
                    completion: completion
                )
            }
        } else if let webBase = session.checkoutUrls?.webApprovalUrl,
            let sessionID = session.sessionId {
            await launchVaultBrowser(
                base: webBase,
                setupTokenID: setupTokenID,
                sessionID: sessionID,
                completion: completion
            )
        } else {
            await launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
        }
    }

    private func launchLegacyWebVault(
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        var vaultURLComponents = URLComponents(
            url: config.environment.paypalVaultCheckoutURL,
            resolvingAgainstBaseURL: false
        )
        vaultURLComponents?.queryItems = [
            URLQueryItem(name: "approval_session_id", value: setupTokenID),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]

        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }

        await launchVaultBrowserURL(vaultCheckoutURL, completion: completion)
    }

    private func fallbackPatchCCO(
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        do {
            let eligibility = try await patchCCOAPI.patchCCOWithAppSwitchEligibility(
                token: orderID,
                tokenType: PayPalCoreConstants.tokenTypeOrderID,
                paypalNativeAppInstalled: application.isPayPalAppInstalled()
            )

            if eligibility.appSwitchEligible == true,
                let urlString = eligibility.redirectURL,
                let url = URL(string: urlString) {
                await MainActor.run { appSwitchCompletion = completion }
                await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.appSwitch)
                let opened = await openURL(url)
                if opened {
                    analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:succeeded")
                } else {
                    analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:failed")
                    await MainActor.run { appSwitchCompletion = nil }
                    await launchLegacyWebCheckout(orderID: orderID, completion: completion)
                }
            } else {
                await launchLegacyWebCheckout(orderID: orderID, completion: completion)
            }
        } catch {
            await launchLegacyWebCheckout(orderID: orderID, completion: completion)
        }
    }

    private func launchLegacyWebCheckout(
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        do {
            _ = try await clientConfigAPI.updateClientConfig(
                token: orderID,
                fundingSource: PayPalCoreConstants.patchCCOFundingSourcePayPal
            )
        } catch {
            print("updateClientConfig error: \(error.localizedDescription)")
        }

        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString =
            "\(baseURLString)/checkoutnow?token=\(orderID)" +
            "&fundingSource=\(PayPalCoreConstants.patchCCOFundingSourcePayPal)" +
            "&integration_artifact=\(PayPalCoreConstants.integrationArtifact)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
            let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
            notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }

        await startWebAuthenticationSession(url: payPalCheckoutURLComponents, completion: completion)
    }

    private func launchCheckoutBrowser(
        base: String,
        orderID: String,
        sessionID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        let urlString = PayPalWebCheckoutURLBuilder.checkoutBrowserURL(
            base: base,
            orderID: orderID,
            sessionID: sessionID
        )
        guard let url = URL(string: urlString) else {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
            notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        await startWebAuthenticationSession(url: url, completion: completion)
    }

    private func launchVaultBrowser(
        base: String,
        setupTokenID: String,
        sessionID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        let urlString = PayPalWebCheckoutURLBuilder.vaultBrowserURL(
            base: base,
            setupTokenID: setupTokenID,
            sessionID: sessionID
        )
        guard let url = URL(string: urlString) else {
            await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.error)
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        await launchVaultBrowserURL(url, completion: completion)
    }

    private func launchVaultBrowserURL(
        _ url: URL,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) async {
        await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.browser)
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { [weak self] url, error in
                self?.handleVaultWebSessionComplete(url: url, error: error, completion: completion)
            }
        )
    }

    private func startWebAuthenticationSession(
        url: URL,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) async {
        await sendSystemLatencyEventIfNeeded(presentationType: PayPalWebAnalytics.PresentationType.browser)
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("paypal-web-payments:checkout:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("paypal-web-payments:checkout:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { [weak self] url, error in
                self?.handleCheckoutWebSessionComplete(url: url, error: error, completion: completion)
            }
        )
    }

    private func handleCheckoutWebSessionComplete(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        if let error = error {
            let sdkError: CoreSDKError
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                sdkError = PayPalError.checkoutCanceledError
            default:
                sdkError = PayPalError.webSessionError(error)
            }
            notifyCheckoutFailure(with: sdkError, completion: completion)
            return
        }

        guard let url = url else { return }

        if let opType = getQueryStringParameter(url: url.absoluteString, param: "opType"), opType == "cancel" {
            notifyCheckoutCancelWithError(with: PayPalError.checkoutCanceledError, completion: completion)
        } else if let orderID = getQueryStringParameter(url: url.absoluteString, param: "token"),
            let payerID = getQueryStringParameter(url: url.absoluteString, param: "PayerID") {
            let result = PayPalWebCheckoutResult(orderID: orderID, payerID: payerID)
            notifyCheckoutSuccess(for: result, completion: completion)
        } else {
            notifyCheckoutFailure(with: PayPalError.malformedResultError, completion: completion)
        }
    }

    private func handleVaultWebSessionComplete(
        url: URL?,
        error: Error?,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        if let error = error {
            let sdkError: CoreSDKError
            switch error {
            case ASWebAuthenticationSessionError.canceledLogin:
                sdkError = PayPalError.vaultCanceledError
            default:
                sdkError = PayPalError.webSessionError(error)
            }
            notifyVaultCancelWithError(with: sdkError, completion: completion)
            return
        }

        guard let url = url else { return }

        if url.path.contains("cancel") {
            notifyVaultCancelWithError(with: PayPalError.vaultCanceledError, completion: completion)
        } else if let tokenID = getQueryStringParameter(url: url.absoluteString, param: "approval_token_id"),
            let approvalSessionID = getQueryStringParameter(url: url.absoluteString, param: "approval_session_id"),
            !tokenID.isEmpty, !approvalSessionID.isEmpty {
            let result = PayPalVaultResult(tokenID: tokenID, approvalSessionID: approvalSessionID)
            notifyVaultSuccess(for: result, completion: completion)
        } else {
            notifyVaultFailure(with: PayPalError.payPalVaultResponseError, completion: completion)
        }
    }

    private func makeCompletionOnce(
        _ completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) -> (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void {
        var shouldInvokeCompletion = true
        return { result in
            Self.serialDispatchQueue.async {
                guard shouldInvokeCompletion else { return }
                shouldInvokeCompletion = false
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
        let bundleID = PayPalCoreConstants.callbackURLScheme
        let redirectURLString = "\(bundleID)://\(PayPalCoreConstants.checkoutCallbackPath)"
        let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: redirectURLString)
        let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")

        var checkoutURLComponents = URLComponents(url: payPalCheckoutURL, resolvingAgainstBaseURL: false)
        checkoutURLComponents?.queryItems?.append(redirectQueryItem)
        checkoutURLComponents?.queryItems?.append(nativeXOQueryItem)

        return checkoutURLComponents?.url
    }

    @MainActor
    private func openURL(_ url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            application.open(url) { success in
                continuation.resume(returning: success)
            }
        }
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func mapError(_ error: Error) -> CoreSDKError {
        error as? CoreSDKError ?? PayPalError.webSessionError(error)
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

    private func makeAnalyticsService(orderID: String? = nil, setupToken: String? = nil) -> AnalyticsService {
        if let unitTestAnalyticsServiceProvider {
            return unitTestAnalyticsServiceProvider(config, orderID, setupToken)
        }

        if let orderID {
            return AnalyticsService(coreConfig: config, orderID: orderID)
        }
        if let setupToken {
            return AnalyticsService(coreConfig: config, setupToken: setupToken)
        }
        return AnalyticsService(coreConfig: config)
    }

    private func sendAPIRequestLatencyEvent(
        startTime: Int64,
        endTime: Int64,
        endpoint: String,
        orderID: String? = nil,
        setupTokenID: String? = nil
    ) async {
        let service: AnalyticsService
        if let analyticsService {
            service = analyticsService
        } else if let orderID {
            service = makeAnalyticsService(orderID: orderID)
        } else if let setupTokenID {
            service = makeAnalyticsService(setupToken: setupTokenID)
        } else {
            service = makeAnalyticsService()
        }

        await service.sendEventAndAwaitDelivery(
            PayPalWebAnalytics.apiRequestLatency,
            startTime: startTime,
            endTime: endTime,
            endpoint: endpoint
        )
    }

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
        with vaultError: CoreSDKError,
        completion: (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("paypal-web-payments:vault-wo-purchase:canceled")
        completion(.failure(vaultError))
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension PayPalWebCheckoutClient: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 16, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return scene?.keyWindow ?? ASPresentationAnchor()
        } else if #available(iOS 15, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return scene?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }
    }
}
// swiftlint:enable type_body_length file_length
