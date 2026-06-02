import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

/// `VenmoClient` handles Venmo checkout flows. It checks funding eligibility, updates client
/// configuration, and launches the Venmo app or system browser for the user to complete payment.
public class VenmoClient {

    static let serialDispatchQueue =
        DispatchQueue(label: "com.paypal.ios.VenmoClient.serialDispatchQueue")

    let config: CoreConfig

    var appSwitchCompletion: ((Result<VenmoCheckoutResult, CoreSDKError>) -> Void)?
    var application: URLOpener = UIApplication.shared

    private let clientConfigAPI: UpdateClientConfigAPI
    private let fundingEligibilityAPI: GetFundingEligibilityAPI
    private var analyticsService: AnalyticsService?

    // MARK: - Public Initializer

    /// Initialize a `VenmoClient` to process Venmo checkout transactions.
    /// - Parameter config: The `CoreConfig` object.
    public init(config: CoreConfig) {
        self.config = config
        self.clientConfigAPI = UpdateClientConfigAPI(coreConfig: config)
        self.fundingEligibilityAPI = GetFundingEligibilityAPI(coreConfig: config)
    }

    // MARK: - Internal Initializer

    /// For internal use for testing/mocking purposes.
    init(
        config: CoreConfig,
        clientConfigAPI: UpdateClientConfigAPI,
        fundingEligibilityAPI: GetFundingEligibilityAPI
    ) {
        self.config = config
        self.clientConfigAPI = clientConfigAPI
        self.fundingEligibilityAPI = fundingEligibilityAPI
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

    // MARK: - Return URL Handling

    /// Handle the return URL from Venmo app switch or browser redirect.
    ///
    /// Call this method from your app's `.onOpenURL` modifier or `SceneDelegate`
    /// when the user returns from Venmo.
    /// - Parameter url: The URL received by the app.
    public func handleReturnURL(_ url: URL) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []

        func queryValue(_ name: String) -> String? {
            items.first { $0.name.compare(name) == .orderedSame }?.value
        }

        let path = url.path.lowercased()
        let isCancel = path.contains("/cancel")

        let orderID = queryValue("token")
        let payerID = queryValue("PayerID")
        let hasCheckoutSuccess = (orderID?.isEmpty == false) && (payerID?.isEmpty == false)

        if isCancel {
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                notifyCanceled(completion: completion)
                return
            }
            return
        }

        if hasCheckoutSuccess, let oid = orderID, let pid = payerID {
            if let completion = appSwitchCompletion {
                appSwitchCompletion = nil
                let result = VenmoCheckoutResult(orderID: oid, payerID: pid)
                notifySuccess(for: result, completion: completion)
                return
            }
        }

        if let completion = appSwitchCompletion {
            appSwitchCompletion = nil
            notifyFailure(with: VenmoError.malformedResultError, completion: completion)
        }
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

        // Step 3: Construct checkout URL
        guard let checkoutURL = constructCheckoutURL(request: request) else {
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
            return
        }

        // Step 4: Store completion and launch
        await MainActor.run {
            appSwitchCompletion = completion
        }

        let venmoAppInstalled = application.isVenmoAppInstalled()

        if venmoAppInstalled {
            analyticsService?.sendEvent("venmo-payments:checkout:venmo-app-installed")
        } else {
            analyticsService?.sendEvent("venmo-payments:checkout:fallback-to-web")
        }

        // Both paths use UIApplication.open — either Venmo app handles the URL or system browser does
        let opened = await openURL(checkoutURL)

        if opened {
            analyticsService?.sendEvent("venmo-payments:checkout:app-switch-open:succeeded")
        } else {
            analyticsService?.sendEvent("venmo-payments:checkout:app-switch-open:failed")
            await MainActor.run {
                appSwitchCompletion = nil
            }
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
        }
    }

    private func constructCheckoutURL(request: VenmoCheckoutRequest) -> URL? {
        let baseURL = config.environment.venmoCheckoutBaseURL

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)

        let callbackScheme = PayPalCoreConstants.callbackURLScheme
        let returnURL = "\(callbackScheme)://x-callback-url/paypal-sdk/venmo-checkout"

        components?.queryItems = [
            URLQueryItem(name: "buttonSessionID", value: UUID().uuidString),
            URLQueryItem(name: "buyerCountry", value: request.buyerCountry),
            URLQueryItem(name: "channel", value: "MOBILE"),
            URLQueryItem(name: "commit", value: "true"),
            URLQueryItem(name: "domain", value: "sdk.paypal.com"),
            URLQueryItem(name: "enableFunding", value: "venmo"),
            URLQueryItem(name: "env", value: config.environment.venmoEnvironmentString),
            URLQueryItem(name: "fundingSource", value: "venmo"),
            URLQueryItem(name: "orderID", value: request.orderID),
            URLQueryItem(name: "pageUrl", value: returnURL),
            URLQueryItem(name: "sessionUID", value: UUID().uuidString)
        ]

        return components?.url
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
