import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// `VenmoClient` handles Venmo checkout flows.
///
/// - Note: This client is currently a scaffold. Calling `start(_:)` will throw
///   `VenmoError.unimplemented`. Full checkout support will be added in a future release.
public final class VenmoClient {

    let config: CoreConfig
    private let networkingClient: NetworkingClient

    /// Initialize a `VenmoClient` to process Venmo checkout transactions.
    /// - Parameter config: The `CoreConfig` object.
    public init(config: CoreConfig) {
        self.config = config
        self.networkingClient = NetworkingClient(coreConfig: config)
    }

    /// For internal use for testing/mocking purposes.
    init(config: CoreConfig, networkingClient: NetworkingClient) {
        self.config = config
        self.networkingClient = networkingClient
    }

    /// Start the Venmo checkout flow.
    /// - Parameter request: The `VenmoCheckoutRequest` for the transaction.
    /// - Returns: A `VenmoCheckoutResult` if successful.
    /// - Throws: A `CoreSDKError` describing the failure.
    /// - Note: Currently throws `VenmoError.unimplemented`. Full implementation coming in a future release.
    public func start(_ request: VenmoCheckoutRequest) async throws -> VenmoCheckoutResult {
        throw VenmoError.unimplemented
    }

    /// Handle the return URL from Venmo app switch or browser redirect.
    ///
    /// Call this method from your app's `.onOpenURL` modifier or `SceneDelegate`
    /// when the user returns from Venmo.
    /// - Parameter url: The URL received by the app.
    public func handleReturnURL(_ url: URL) {
        // TODO: Phase 3 — parse return URL and resume in-flight checkout
    }
}
