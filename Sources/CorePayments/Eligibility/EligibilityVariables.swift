import Foundation

struct EligibilityVariables {
    
    private let eligibilityRequest: EligibilityRequest
    private let clientID: String
 
    // MARK: - Initializer
    
    init(eligibilityRequest: EligibilityRequest, clientID: String) {
        self.eligibilityRequest = eligibilityRequest
        self.clientID = clientID
    }
}
