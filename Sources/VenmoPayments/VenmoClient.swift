import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

public class VenmoClient {
    
    // MARK: - Properties
    
    private let config: CoreConfig
    private let universalLink: URL
    private let networkingClient: NetworkingClient
    
    // MARK: - Initializers
    
    ///  Initialize a VenmoClient to process a Venmo payment
    ///  - Parameter config: The CoreConfig object
    ///  - Parameter universalLink: The URL to use for the Venmo app switch checkout flow. 
    public init(config: CoreConfig, universalLink: URL) {
        self.config = config
        self.universalLink = universalLink
        self.networkingClient = NetworkingClient(coreConfig: config)
    }
    
    /// For internal use for testing/mocking purpose
    init(config: CoreConfig, universalLink: URL, networkingClient: NetworkingClient) {
        self.config = config
        self.universalLink = universalLink
        self.networkingClient = networkingClient
    }
    
    /// Launch the Venmo checkout flow
    /// - Parameters:
    ///     - request: the `VenmoCheckoutRequest` for the transaction
    /// - Returns: A `VenmoCheckoutResult`
    /// - Throws: An `Error` describing the failure
    public func start(_ request: VenmoCheckoutRequest) async throws -> VenmoCheckoutResult {
        // TODO: - Add logic in a future PR
        VenmoCheckoutResult(orderID: "test-order-id")
    }
}
