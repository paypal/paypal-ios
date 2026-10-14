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
        case billingAddress
    }

    private enum BillingAddressKeys: String, CodingKey {
        case addressLine1
        case addressLine2
        case adminArea1
        case adminArea2
        case postalCode
        case countryCode
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
        if let billingAddress = vaultRequest.card.billingAddress {
            try encode(billingAddress, into: &card)
        }
    }

    private func encode(
        _ billingAddress: Address,
        into card: inout KeyedEncodingContainer<CardKeys>
    ) throws {
        var address = card.nestedContainer(keyedBy: BillingAddressKeys.self, forKey: .billingAddress)
        try address.encodeIfPresent(billingAddress.addressLine1, forKey: .addressLine1)
        try address.encodeIfPresent(billingAddress.addressLine2, forKey: .addressLine2)
        try address.encodeIfPresent(billingAddress.region, forKey: .adminArea1)
        try address.encodeIfPresent(billingAddress.locality, forKey: .adminArea2)
        try address.encodeIfPresent(billingAddress.postalCode, forKey: .postalCode)
        try address.encode(billingAddress.countryCode, forKey: .countryCode)
    }
}
