import Foundation

struct EligibilityVariables: Encodable {
    
    let eligibilityRequest: EligibilityRequest
    let clientID: String
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case clientID = "clientId"
        case intent
        case currency
        case enableFunding
    }
    
    // MARK: - Custom Encoder
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientID, forKey: .clientID)
        try container.encode(eligibilityRequest.intent.rawValue, forKey: .intent)
        try container.encode(eligibilityRequest.currency, forKey: .currency)
        
        let enableFunding = eligibilityRequest.enableFunding.compactMap { $0.rawValue }
        try container.encode(enableFunding, forKey: .enableFunding)
    }
}
