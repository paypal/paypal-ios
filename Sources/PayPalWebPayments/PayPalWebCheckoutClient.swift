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

        Task {
            if request.userAction == .setupNow {
                notifyCheckoutFailure(with: PayPalError.invalidUserActionError, completion: completionOnce)
                return
            }

            do {
                async let sessionTask = createShopperSessionAPI.createShopperSessionForCheckout(
                    request: request,
                    paypalAppInstalled: application.isPayPalAppInstalled(),
                    venmoAppInstalled: application.isVenmoAppInstalled()
                )
                async let orderIDTask = createOrder()

                let orderID = try await orderIDTask
                analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)
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
        Task {
            do {
                async let sessionTask = createShopperSessionAPI.createShopperSessionForVault(
                    request: vaultRequest,
                    paypalAppInstalled: application.isPayPalAppInstalled(),
                    venmoAppInstalled: application.isVenmoAppInstalled()
                )
                async let setupTokenTask = createSetupToken()

                let setupTokenID = try await setupTokenTask
                analyticsService = AnalyticsService(coreConfig: config, setupToken: setupTokenID)
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
                        launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
                    }
                } catch {
                    launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
                }
            } catch {
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
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []
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
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            await MainActor.run { appSwitchCompletion = completion }

            let opened = await openURL(url, universalLinksOnly: true)
            if opened {
                analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:succeeded")
            } else {
                analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:failed")
                await MainActor.run { appSwitchCompletion = nil }
                if let webBase = session.checkoutUrls?.webCheckoutWeb,
                    let sessionID = session.sessionId {
                    launchCheckoutBrowser(
                        base: webBase,
                        orderID: orderID,
                        sessionID: sessionID,
                        completion: completion
                    )
                } else {
                    notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                }
            }
        } else if let webBase = session.checkoutUrls?.webCheckoutWeb,
            let sessionID = session.sessionId {
            launchCheckoutBrowser(
                base: webBase,
                orderID: orderID,
                sessionID: sessionID,
                completion: completion
            )
        } else {
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
                notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            await MainActor.run { vaultAppSwitchCompletion = completion }

            let opened = await openURL(url, universalLinksOnly: true)
            if !opened,
                let webBase = session.checkoutUrls?.webApprovalUrl,
                let sessionID = session.sessionId {
                await MainActor.run { vaultAppSwitchCompletion = nil }
                launchVaultBrowser(
                    base: webBase,
                    setupTokenID: setupTokenID,
                    sessionID: sessionID,
                    completion: completion
                )
            }
        } else if let webBase = session.checkoutUrls?.webApprovalUrl,
            let sessionID = session.sessionId {
            launchVaultBrowser(
                base: webBase,
                setupTokenID: setupTokenID,
                sessionID: sessionID,
                completion: completion
            )
        } else {
            launchLegacyWebVault(setupTokenID: setupTokenID, completion: completion)
        }
    }

    private func launchLegacyWebVault(
        setupTokenID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        var vaultURLComponents = URLComponents(
            url: config.environment.paypalVaultCheckoutURL,
            resolvingAgainstBaseURL: false
        )
        vaultURLComponents?.queryItems = [
            URLQueryItem(name: "approval_session_id", value: setupTokenID),
            URLQueryItem(name: "integration_artifact", value: PayPalCoreConstants.integrationArtifact)
        ]

        guard let vaultCheckoutURL = vaultURLComponents?.url else {
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }

        launchVaultBrowserURL(vaultCheckoutURL, completion: completion)
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
                let opened = await openURL(url, universalLinksOnly: true)
                if opened {
                    analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:succeeded")
                } else {
                    analyticsService?.sendEvent("paypal-web-payments:checkout:app-switch-open:failed")
                    await MainActor.run { appSwitchCompletion = nil }
                    launchLegacyWebCheckout(orderID: orderID, completion: completion)
                }
            } else {
                launchLegacyWebCheckout(orderID: orderID, completion: completion)
            }
        } catch {
            launchLegacyWebCheckout(orderID: orderID, completion: completion)
        }
    }

    private func launchLegacyWebCheckout(
        orderID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        Task {
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
                notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
                return
            }

            startWebAuthenticationSession(url: payPalCheckoutURLComponents, completion: completion)
        }
    }

    private func launchCheckoutBrowser(
        base: String,
        orderID: String,
        sessionID: String,
        completion: @escaping (Result<PayPalWebCheckoutResult, CoreSDKError>) -> Void
    ) {
        let urlString = PayPalWebCheckoutURLBuilder.checkoutBrowserURL(
            base: base,
            orderID: orderID,
            sessionID: sessionID
        )
        guard let url = URL(string: urlString) else {
            notifyCheckoutFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        startWebAuthenticationSession(url: url, completion: completion)
    }

    private func launchVaultBrowser(
        base: String,
        setupTokenID: String,
        sessionID: String,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
        let urlString = PayPalWebCheckoutURLBuilder.vaultBrowserURL(
            base: base,
            setupTokenID: setupTokenID,
            sessionID: sessionID
        )
        guard let url = URL(string: urlString) else {
            notifyVaultFailure(with: PayPalError.payPalURLError, completion: completion)
            return
        }
        launchVaultBrowserURL(url, completion: completion)
    }

    private func launchVaultBrowserURL(
        _ url: URL,
        completion: @escaping (Result<PayPalVaultResult, CoreSDKError>) -> Void
    ) {
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
    ) {
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
    private func openURL(_ url: URL, universalLinksOnly: Bool) async -> Bool {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] =
            universalLinksOnly ? [.universalLinksOnly: true] : [:]
        return await withCheckedContinuation { continuation in
            application.open(url, options: options) { success in
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
