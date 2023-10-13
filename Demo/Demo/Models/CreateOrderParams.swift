struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var paymentSource: VaultCardPaymentSource?
}

struct PurchaseUnit: Codable {

    let amount: Amount
    // TODO: payee information for connected_partner
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}

struct Vault: Codable {

    let storeInVault: String
}


struct Attributes: Codable {

    let vault: Vault
    let customer: CardVaultCustomer?
}

struct CardVaultCustomer: Codable {

    let id: String
}

struct VaultCard: Codable {

    let attributes: Attributes
}

struct VaultCardPaymentSource: Codable {

    let card: VaultCard
}
