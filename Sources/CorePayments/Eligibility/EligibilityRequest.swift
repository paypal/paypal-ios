import Foundation

public struct EligibilityRequest {

    public let intent: String
    public let currency: String
    public let enableFunding: [String]
    
    // MARK: - Initializer
    
    public init(intent: String, currency: String, enableFunding: [String]) {
        self.intent = intent
        self.currency = currency
        self.enableFunding = enableFunding
    }
}
