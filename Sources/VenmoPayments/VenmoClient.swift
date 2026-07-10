import Foundation
import UIKit
import AuthenticationServices

#if canImport(CorePayments)
import CorePayments
#endif

/// `VenmoClient` handles Venmo checkout flows. When the merchant opts into app switch and the Venmo
/// app is installed, it launches the Venmo app for approval; otherwise it presents checkout in a web
/// authentication session. It also checks funding eligibility and updates client configuration.
public class VenmoClient: NSObject {

    static let serialDispatchQueue =
        DispatchQueue(label: "com.paypal.ios.VenmoClient.serialDispatchQueue")

    let config: CoreConfig

    var appSwitchCompletion: ((Result<VenmoCheckoutResult, CoreSDKError>) -> Void)?
    var application: URLOpener = UIApplication.shared

    private let clientConfigAPI: UpdateClientConfigAPI
    private let fundingEligibilityAPI: GetFundingEligibilityAPI
    private let webAuthenticationSession: WebAuthenticationSession
    private var analyticsService: AnalyticsService?

    // MARK: - Public Initializer

    /// Initialize a `VenmoClient` to process Venmo checkout transactions.
    /// - Parameter config: The `CoreConfig` object.
    public init(config: CoreConfig) {
        self.config = config
        self.clientConfigAPI = UpdateClientConfigAPI(coreConfig: config)
        self.fundingEligibilityAPI = GetFundingEligibilityAPI(coreConfig: config)
        self.webAuthenticationSession = WebAuthenticationSession()
        super.init()
    }

    // MARK: - Internal Initializer

    /// For internal use for testing/mocking purposes.
    init(
        config: CoreConfig,
        clientConfigAPI: UpdateClientConfigAPI,
        fundingEligibilityAPI: GetFundingEligibilityAPI,
        webAuthenticationSession: WebAuthenticationSession = WebAuthenticationSession()
    ) {
        self.config = config
        self.clientConfigAPI = clientConfigAPI
        self.fundingEligibilityAPI = fundingEligibilityAPI
        self.webAuthenticationSession = webAuthenticationSession
        super.init()
    }

    // MARK: - Checkout (Completion Handler)

    /// Start the Venmo checkout flow.
    /// - Parameters:
    ///   - request: The `VenmoCheckoutRequest` for the transaction.
    ///   - completion: A completion block invoked when the request is completed.
    ///                 The closure returns a `Result`:
    ///                 - `.success(VenmoCheckoutResult)` containing `orderID` and `payerID`.
    ///                 - `.failure(CoreSDKError)` describing the reason for failure.
    public func start(
        request: VenmoCheckoutRequest,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("venmo-payments:checkout:started")

        let completionOnce = makeCompletionOnce(completion)

        Task {
            await performCheckoutFlow(request: request, completion: completionOnce)
        }
    }

    // MARK: - Checkout (Async/Await)

    /// Start the Venmo checkout flow.
    /// - Parameter request: The `VenmoCheckoutRequest` for the transaction.
    /// - Returns: A `VenmoCheckoutResult` if successful.
    /// - Throws: A `CoreSDKError` describing the failure.
    public func start(request: VenmoCheckoutRequest) async throws -> VenmoCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(request: request) { result in
                switch result {
                case .success(let checkoutResult):
                    continuation.resume(returning: checkoutResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Build the Venmo app-switch checkout URL.
    ///
    /// Mirrors the Android app-switch contract: the Venmo pay sheet bootstraps from these query
    /// parameters, so all of them must be present for it to load.
    /// - Parameter request: The `VenmoCheckoutRequest` for the transaction.
    /// - Returns: The fully constructed checkout URL.
    /// - Throws: `VenmoError.venmoURLError` if URL construction fails.
    func buildCheckoutURL(request: VenmoCheckoutRequest) throws -> URL {
        let baseURL = config.environment.venmoBaseURL
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = "/go/web/paypal"

        // `buttonSessionID` and `sessionUID` share a single session identifier, matching Android.
        let sessionID = UUID().uuidString
        var queryItems = [
            URLQueryItem(name: "buttonSessionID", value: sessionID),
            URLQueryItem(name: "buyerCountry", value: request.buyerCountry),
            URLQueryItem(name: "channel", value: "in-app"),
            URLQueryItem(name: "commit", value: "true"),
            URLQueryItem(name: "domain", value: "sdk.paypal.com"),
            URLQueryItem(name: "enableFunding", value: "venmo"),
            URLQueryItem(name: "env", value: config.environment.venmoEnvironmentString),
            URLQueryItem(name: "fundingSource", value: "venmo"),
            // TODO: (2026-06-02) return_flow may become removable once Direct API is fully rolled out
            URLQueryItem(name: "return_flow", value: "auto"),
            URLQueryItem(name: "token", value: request.orderID)
        ]
        if let returnURL = request.returnURL {
            queryItems.append(URLQueryItem(name: "pageUrl", value: returnURL))
        }
        queryItems.append(URLQueryItem(name: "sessionUID", value: sessionID))
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw VenmoError.venmoURLError
        }
        return url
    }

    /// Build the Venmo web checkout URL used by the web authentication session fallback.
    /// - Parameter orderID: The order ID for the transaction.
    /// - Returns: The constructed web checkout URL, or `nil` if construction fails.
    func buildWebCheckoutURL(orderID: String) -> URL? {
        let baseURL = config.environment.venmoCheckoutBaseURL
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "token", value: orderID),
            URLQueryItem(name: "fundingSource", value: "venmo"),
            URLQueryItem(name: "env", value: config.environment.venmoEnvironmentString),
            URLQueryItem(name: "enableFunding", value: "venmo")
        ]
        return components?.url
    }

    // MARK: - Return URL Handling

    /// Handle the return URL from Venmo app switch.
    ///
    /// Call this method from your app's `.onOpenURL` modifier or `SceneDelegate`
    /// when the user returns from the Venmo app.
    /// - Parameter url: The URL received by the app.
    public func handleReturnURL(_ url: URL) {
        Self.log("handleReturnURL — received: \(url.absoluteString)")
        guard let completion = appSwitchCompletion else {
            Self.log("handleReturnURL — no pending appSwitchCompletion; ignoring")
            return
        }
        appSwitchCompletion = nil
        let parsed = parseVenmoReturn(url)
        Self.log("handleReturnURL — parsed result: \(parsed)")
        deliver(parsed, completion: completion)
    }

    // MARK: - Private Methods

    private func makeCompletionOnce(
        _ completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) -> (Result<VenmoCheckoutResult, CoreSDKError>) -> Void {
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

    private func performCheckoutFlow(
        request: VenmoCheckoutRequest,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) async {
        let venmoAppInstalled = application.isVenmoAppInstalled()
        Self.log("performCheckoutFlow — appSwitchIfEligible=\(request.appSwitchIfEligible), isVenmoAppInstalled=\(venmoAppInstalled)")

        if request.appSwitchIfEligible && venmoAppInstalled {
            Self.log("branch → APP SWITCH")
            analyticsService?.sendEvent("venmo-payments:checkout:venmo-app-installed")
            await attemptAppSwitch(request: request, completion: completion)
        } else {
            Self.log("branch → WEB FLOW (ASWebAuthenticationSession)")
            if request.appSwitchIfEligible {
                analyticsService?.sendEvent("venmo-payments:checkout:fallback-to-web")
            }
            await startWebCheckoutFlow(request: request, completion: completion)
        }
    }

    /// Lightweight debug logging for troubleshooting the app-switch round trip.
    /// TODO: Remove once the Venmo app-switch flow is verified end-to-end.
    static func log(_ message: String) {
        print("🔵 VenmoClient: \(message)")
    }

    /// Attempt to switch to the Venmo app. Falls back to the web flow if the app cannot be opened.
    private func attemptAppSwitch(
        request: VenmoCheckoutRequest,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) async {
        // Prime the order for the Venmo funding source before switching. Matches the Android
        // app-switch flow; without this the Venmo pay sheet may fail to load. Logged but not fatal
        // — consistent with the web checkout flow — so the switch is still attempted on failure.
        do {
            _ = try await clientConfigAPI.updateClientConfig(token: request.orderID, fundingSource: "venmo")
            Self.log("attemptAppSwitch — updateClientConfig succeeded")
        } catch {
            Self.log("attemptAppSwitch — updateClientConfig FAILED: \(error.localizedDescription)")
            analyticsService?.sendEvent("venmo-payments:checkout:update-client-config:failed")
        }

        guard let checkoutURL = try? buildCheckoutURL(request: request) else {
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
            return
        }

        await MainActor.run {
            appSwitchCompletion = completion
        }

        Self.log("attemptAppSwitch — opening URL: \(checkoutURL.absoluteString)")
        let opened = await openURL(checkoutURL)
        Self.log("attemptAppSwitch — UIApplication.open returned: \(opened)")

        if opened {
            analyticsService?.sendEvent("venmo-payments:checkout:app-switch-open:succeeded")
            // Result is delivered later via handleReturnURL when the user returns from the Venmo app.
        } else {
            Self.log("attemptAppSwitch — open failed, falling back to web flow")
            analyticsService?.sendEvent("venmo-payments:checkout:app-switch-open:failed")
            await MainActor.run {
                appSwitchCompletion = nil
            }
            await startWebCheckoutFlow(request: request, completion: completion)
        }
    }

    /// Run funding eligibility + client config, then present checkout in a web authentication session.
    private func startWebCheckoutFlow(
        request: VenmoCheckoutRequest,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) async {
        // Step 1: Check funding eligibility
        do {
            let eligibility = try await fundingEligibilityAPI.getFundingEligibility(
                intent: "capture",
                currency: request.currency,
                enableFunding: ["VENMO"]
            )

            guard eligibility.eligible else {
                let reason = eligibility.reasons?.joined(separator: ", ") ?? "unknown"
                analyticsService?.sendEvent("venmo-payments:checkout:funding-eligibility:ineligible")
                notifyFailure(with: VenmoError.fundingEligibilityError(reason: reason), completion: completion)
                return
            }

            analyticsService?.sendEvent("venmo-payments:checkout:funding-eligibility:eligible")
        } catch {
            analyticsService?.sendEvent("venmo-payments:checkout:funding-eligibility:failed")
            let sdkError = (error as? CoreSDKError) ?? CoreSDKError(
                code: VenmoError.Code.unknown.rawValue,
                domain: VenmoError.domain,
                errorDescription: error.localizedDescription
            )
            notifyFailure(with: sdkError, completion: completion)
            return
        }

        // Step 2: Update client configuration (CCO)
        do {
            _ = try await clientConfigAPI.updateClientConfig(
                token: request.orderID,
                fundingSource: "venmo"
            )
        } catch {
            // Log but don't fail — matches PayPalWebCheckoutClient behavior
            analyticsService?.sendEvent("venmo-payments:checkout:update-client-config:failed")
        }

        // Step 3: Present the web authentication session
        guard let webCheckoutURL = buildWebCheckoutURL(orderID: request.orderID) else {
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
            return
        }

        Self.log("startWebCheckoutFlow — launching web session URL: \(webCheckoutURL.absoluteString)")
        await launchWebAuthenticationSession(url: webCheckoutURL, completion: completion)
    }

    @MainActor
    private func launchWebAuthenticationSession(
        url: URL,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("venmo-payments:checkout:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("venmo-payments:checkout:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { [weak self] url, error in
                guard let self else { return }
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyCanceled(completion: completion)
                    default:
                        self.notifyFailure(with: VenmoError.webSessionError(error), completion: completion)
                    }
                    return
                }

                guard let url = url else {
                    self.notifyFailure(with: VenmoError.malformedResultError, completion: completion)
                    return
                }

                self.deliver(self.parseVenmoReturn(url), completion: completion)
            }
        )
    }

    /// Parse a Venmo return/redirect URL into a checkout result.
    private func parseVenmoReturn(_ url: URL) -> Result<VenmoCheckoutResult, CoreSDKError> {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []

        func queryValue(_ name: String) -> String? {
            items.first { $0.name.compare(name) == .orderedSame }?.value
        }

        let isCancel = url.path.lowercased().contains("/cancel")
        let approved = queryValue("approved")
        let orderID = queryValue("token")
        let payerID = queryValue("PayerID")

        if isCancel || approved == "false" {
            return .failure(VenmoError.checkoutCanceledError)
        }

        if let orderID, let payerID, !orderID.isEmpty, !payerID.isEmpty {
            return .success(VenmoCheckoutResult(orderID: orderID, payerID: payerID))
        }

        return .failure(VenmoError.malformedResultError)
    }

    private func deliver(
        _ result: Result<VenmoCheckoutResult, CoreSDKError>,
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        switch result {
        case .success(let checkoutResult):
            notifySuccess(for: checkoutResult, completion: completion)
        case .failure(let error):
            if VenmoError.isCheckoutCanceled(error) {
                notifyCanceled(completion: completion)
            } else {
                notifyFailure(with: error, completion: completion)
            }
        }
    }

    @MainActor
    private func openURL(_ url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            application.open(url) { success in
                continuation.resume(returning: success)
            }
        }
    }

    private func notifySuccess(
        for result: VenmoCheckoutResult,
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("venmo-payments:checkout:succeeded")
        completion(.success(result))
    }

    private func notifyFailure(
        with error: CoreSDKError,
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("venmo-payments:checkout:failed")
        completion(.failure(error))
    }

    private func notifyCanceled(
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService?.sendEvent("venmo-payments:checkout:canceled")
        completion(.failure(VenmoError.checkoutCanceledError))
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension VenmoClient: ASWebAuthenticationPresentationContextProviding {

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
