import Foundation

/// The `EligibilityClient` class provides methods to check eligibility status based on provided requests.
public final class EligibilityClient {
    
    private let api: EligibilityAPI
    private let config: CoreConfig
    
    // MARK: - Initializers
    
    ///  Initializes a new instance of `EligibilityClient`.
    /// - Parameter config: The core configuration needed for the client.
    public init(config: CoreConfig) {
        self.config = config
        self.api = EligibilityAPI(coreConfig: config)
    }
    
    /// Exposed for injecting MockEligibilityAPI in tests
    init(config: CoreConfig, api: EligibilityAPI) {
        self.config = config
        self.api = api
    }
    
    // MARK: - Public Methods
    
    /// Checks the eligibility based on the provided `EligibilityRequest`.
    ///
    /// This method calls the `EligibilityAPI` to perform the check and converts the response to `EligibilityResult`.
    ///
    /// - Parameter eligibilityRequest: The eligibility request containing the necessary data to perform the check.
    /// - Throws: An error if the network request or parsing fails.
    /// - Returns: An `EligibilityResult` containing the result of the eligibility check.
    public func check(_ eligibilityRequest: EligibilityRequest) async throws -> EligibilityResult {
        try await api.check(eligibilityRequest).asResult
    }
}
