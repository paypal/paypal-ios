import Foundation

public struct EligibilityRequest {

    public let clientId: String
    public let intent: String
    public let currency: String
    public let enableFunding: [String]
    
    public init(clientId: String, intent: String, currency: String, enableFunding: [String]) {
        self.clientId = clientId
        self.intent = intent
        self.currency = currency
        self.enableFunding = enableFunding
    }
}
