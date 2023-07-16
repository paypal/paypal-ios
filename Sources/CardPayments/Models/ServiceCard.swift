import Foundation

/// ServiceCard is used for formatting contents of `CardRequest` for `ConfirmPaymentSourceRequest`
struct ServiceCard: Encodable {
    
    let number: String
    let securityCode: String
    let billingAddress: Address?
    let name: String?
    let expiry: String
    let attributes: Attributes?
    
    enum CodingKeys: String, CodingKey {
        case number
        case expiry
        case securityCode
        case name
        case billingAddress
        case attributes
    }
    
    init(cardRequest: CardRequest) {
        let card = cardRequest.card
        self.number = card.number
        self.securityCode = card.securityCode
        self.billingAddress = card.billingAddress
        self.name = card.cardholderName
        self.expiry = "\(card.expirationYear)-\(card.expirationMonth)"
        attributes = Attributes(
            vault: cardRequest.vault, verificationMethod: cardRequest.sca.rawValue
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(expiry, forKey: .expiry)
        try container.encode(securityCode, forKey: .securityCode)
        try container.encode(name, forKey: .name)
        try container.encode(billingAddress, forKey: .billingAddress)
        try container.encode(attributes, forKey: .attributes)
    }
}

struct Attributes: Codable {

    var customer: Customer?
    var vault: CardVault?
    let verification: Verification
    
    init(vault: Vault? = nil, verificationMethod: String) {
        self.verification = Verification(method: verificationMethod)
        if let vault = vault {
            self.vault = CardVault(storeInVault: .onSuccess)
            if let id = vault.customerID {
                self.customer = Customer(id: id)
            }
        }
    }
}

struct Verification: Codable {

    let method: String
}

struct Customer: Codable {
    
    let id: String
}

enum StoreInVault: String, Codable {
    case onSuccess = "ON_SUCCESS"
}

struct CardVault: Codable {
    
    let storeInVault: StoreInVault
}
