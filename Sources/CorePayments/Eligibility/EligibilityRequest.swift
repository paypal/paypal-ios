import Foundation

public struct EligibilityRequest {

    let intent: String
    let currency: String
    let enableFunding: [String]
    
    // MARK: - Initializer
    
    public init(intent: String, currency: String, enableFunding: [String]) {
        self.intent = intent
        self.currency = currency
        self.enableFunding = enableFunding
    }
}
