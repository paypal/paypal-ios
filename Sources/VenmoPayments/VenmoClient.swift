import Foundation
import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

/// `VenmoClient` handles Venmo checkout flows. It opens the Venmo checkout URL, which switches to the
/// Venmo app when installed and otherwise opens in Safari, and updates client configuration.
public class VenmoClient: NSObject {

    static let serialDispatchQueue =
        DispatchQueue(label: "com.paypal.ios.VenmoClient.serialDispatchQueue")

    let config: CoreConfig

    var appSwitchCompletion: ((Result<VenmoCheckoutResult, CoreSDKError>) -> Void)?
    var application: URLOpener = UIApplication.shared

    private let clientConfigAPI: UpdateClientConfigAPI
    private var analyticsService: AnalyticsService?
    private let checkoutAnalyticsData = PayPalCheckoutAnalyticsData()

    // MARK: - Public Initializer

    /// Initialize a `VenmoClient` to process Venmo checkout transactions.
    /// - Parameter config: The `CoreConfig` object.
    public convenience init(config: CoreConfig) {
        self.init(
            config: config,
            clientConfigAPI: UpdateClientConfigAPI(coreConfig: config)
        )
    }

    // MARK: - Internal Initializer

    /// For internal use for testing/mocking purposes.
    init(
        config: CoreConfig,
        clientConfigAPI: UpdateClientConfigAPI
    ) {
        self.config = config
        self.clientConfigAPI = clientConfigAPI
        super.init()
    }

    // MARK: - Checkout (Completion Handler)

    /// Start the Venmo checkout flow. Opens the Venmo checkout URL: the OS switches to the Venmo app when it
    /// handles the link, otherwise the URL opens in Safari. The result is delivered via `handleReturnURL(_:)`.
    /// - Parameters:
    ///   - orderID: The ID of the order to be approved.
    ///   - completion: A completion block invoked when the request is completed.
    ///                 The closure returns a `Result`:
    ///                 - `.success(VenmoCheckoutResult)` containing `orderID` and `payerID`.
    ///                 - `.failure(CoreSDKError)` describing the reason for failure.
    public func start(
        orderID: String,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)

        let completionOnce = makeCompletionOnce(completion)

        Task {
            await performCheckoutFlow(orderID: orderID, completion: completionOnce)
        }
    }

    // MARK: - Checkout (Async/Await)

    /// Start the Venmo checkout flow.
    /// - Parameter orderID: The ID of the order to be approved.
    /// - Returns: A `VenmoCheckoutResult` if successful.
    /// - Throws: A `CoreSDKError` describing the failure.
    public func start(orderID: String) async throws -> VenmoCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            start(orderID: orderID) { result in
                switch result {
                case .success(let checkoutResult):
                    continuation.resume(returning: checkoutResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Build the Venmo checkout URL (`channel` and `token`).
    /// - Parameter orderID: The ID of the order to be approved.
    /// - Returns: The constructed checkout URL.
    /// - Throws: `VenmoError.venmoURLError` if URL construction fails.
    func buildCheckoutURL(orderID: String) throws -> URL {
        let baseURL = config.environment.venmoBaseURL
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = "/go/web/paypal"
        components?.queryItems = [
            URLQueryItem(name: "channel", value: "in-app"),
            URLQueryItem(name: "token", value: orderID)
        ]

        guard let url = components?.url else {
            throw VenmoError.venmoURLError
        }
        return url
    }

    // MARK: - Return URL Handling

    /// Handle the return URL from Venmo (app or web).
    ///
    /// Call this method from your app's `.onOpenURL` modifier or `SceneDelegate`
    /// when the user returns from Venmo.
    /// - Parameter url: The URL received by the app.
    public func handleReturnURL(_ url: URL) {
        guard let completion = appSwitchCompletion else {
            return
        }
        appSwitchCompletion = nil
        deliver(parseVenmoReturn(url), completion: completion)
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
        orderID: String,
        completion: @escaping (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) async {
        checkoutAnalyticsData.venmoInstalled = await isVenmoAppInstalled()
        sendEvent("venmo-payments:checkout:started")

        // Update client config; ignore failure as the transaction should proceed regardless.
        do {
            _ = try await clientConfigAPI.updateClientConfig(token: orderID, fundingSource: "venmo")
        } catch {
            sendEvent("venmo-payments:checkout:update-client-config:failed")
        }

        guard let checkoutURL = try? buildCheckoutURL(orderID: orderID) else {
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
            return
        }

        await MainActor.run {
            appSwitchCompletion = completion
        }

        let opened = await openURL(checkoutURL, universalLinksOnly: false)

        if opened {
            sendEvent("venmo-payments:checkout:auth-challenge-presentation:succeeded")
            // Result is delivered later via handleReturnURL.
        } else {
            sendEvent("venmo-payments:checkout:auth-challenge-presentation:failed")
            await MainActor.run {
                appSwitchCompletion = nil
            }
            notifyFailure(with: VenmoError.venmoURLError, completion: completion)
        }
    }

    private func sendEvent(_ name: String) {
        analyticsService?.sendEvent(name, checkoutAnalyticsData: checkoutAnalyticsData)
    }

    @MainActor
    private func isVenmoAppInstalled() -> Bool {
        application.isVenmoAppInstalled()
    }

    /// Parse a Venmo return/redirect URL into a checkout result.
    private func parseVenmoReturn(_ url: URL) -> Result<VenmoCheckoutResult, CoreSDKError> {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []

        func queryValue(_ name: String) -> String? {
            items.first { $0.name.compare(name) == .orderedSame }?.value
        }

        let orderID = queryValue("token") ?? ""
        let canceled = queryValue("canceled")?.lowercased() == "true"
        let approved = queryValue("approved")?.lowercased() == "true"

        if canceled {
            return .failure(VenmoError.checkoutCanceledError)
        }

        if approved {
            guard let payerID = queryValue("PayerID"), !payerID.isEmpty else {
                return .failure(VenmoError.malformedResultError)
            }
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
    private func openURL(_ url: URL, universalLinksOnly: Bool = true) async -> Bool {
        await withCheckedContinuation { continuation in
            application.open(url, universalLinksOnly: universalLinksOnly) { success in
                continuation.resume(returning: success)
            }
        }
    }

    private func notifySuccess(
        for result: VenmoCheckoutResult,
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        sendEvent("venmo-payments:checkout:succeeded")
        completion(.success(result))
    }

    private func notifyFailure(
        with error: CoreSDKError,
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        sendEvent("venmo-payments:checkout:failed")
        completion(.failure(error))
    }

    private func notifyCanceled(
        completion: (Result<VenmoCheckoutResult, CoreSDKError>) -> Void
    ) {
        sendEvent("venmo-payments:checkout:canceled")
        completion(.failure(VenmoError.checkoutCanceledError))
    }
}
