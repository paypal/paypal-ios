struct CreateOrderParams: Encodable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var paymentSource: VaultCardPaymentSource?
}

struct VaultCardPaymentSource: Encodable {

    let card: VaultCard
}

struct VaultCard: Encodable {

    let attributes: Attributes
}

struct Attributes: Encodable {

    let vault: Vault
    let customer: CardVaultCustomer?
}

struct Vault: Encodable {

    let storeInVault: String
}

struct CardVaultCustomer: Encodable {

    let id: String
}

struct PurchaseUnit: Encodable {

    let amount: Amount
    // TODO: payee information for connected_partner
}

struct Amount: Encodable {

    let currencyCode: String
    let value: String
}
