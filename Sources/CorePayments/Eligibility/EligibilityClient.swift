import Foundation

public final class EligibilityClient {
    
    private let config: CoreConfig
    private let eligibilityAPI: EligibilityAPI
    
    public init(config: CoreConfig) {
        self.config = config
        self.eligibilityAPI = EligibilityAPI(coreConfig: config)
    }
    
    public func check(_ eligibilityRequest: EligibilityRequest = .init()) async throws -> EligibilityResult {
        try await eligibilityAPI.check(eligibilityRequest).asResult
    }
}
