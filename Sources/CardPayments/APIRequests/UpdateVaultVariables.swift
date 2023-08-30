import Foundation

struct UpdateVaultVariables: Encodable {
    
    // MARK: - Coding Keys
    
    private enum TopLevelKeys: String, CodingKey {
        case clientID
        case vaultSetupToken
        case paymentSource
    }
    
    private  enum PaymentSourceKeys: String, CodingKey {
        case card
    }
    
    private enum CardKeys: String, CodingKey {
        case number
        case securityCode
        case expiry
        case name
    }
    
    // MARK: - Internal Properties
    // Exposed for testing
    
    let vaultRequest: CardVaultRequest
    let clientID: String
 
    // MARK: - Initializer
    
    init(cardVaultRequest: CardVaultRequest, clientID: String) {
        self.vaultRequest = cardVaultRequest
        self.clientID = clientID
    }
        
    // MARK: - Custom Encoder
    
    func encode(to encoder: Encoder) throws {
        var topLevel = encoder.container(keyedBy: TopLevelKeys.self)
        try topLevel.encode(clientID, forKey: .clientID)
        try topLevel.encode(vaultRequest.setupTokenID, forKey: .vaultSetupToken)
        
        var paymentSource = topLevel.nestedContainer(keyedBy: PaymentSourceKeys.self, forKey: .paymentSource)
        
        var card = paymentSource.nestedContainer(keyedBy: CardKeys.self, forKey: .card)
        try card.encode(vaultRequest.card.number, forKey: .number)
        try card.encode(vaultRequest.card.securityCode, forKey: .securityCode)
        try card.encode(vaultRequest.card.expiry, forKey: .expiry)
        try card.encodeIfPresent(vaultRequest.card.cardholderName, forKey: .name)
    }
}
