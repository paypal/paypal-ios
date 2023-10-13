struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var paymentSource: VaultCardPaymentSource?

    init(intent: String, purchaseUnits: [PurchaseUnit]?, shouldVault: Bool = false, customerID: String? = nil) {
        self.intent = intent
        self.purchaseUnits = purchaseUnits
        if shouldVault {
            var customer: CardVaultCustomer?
            if let customerID {
                customer = CardVaultCustomer(id: customerID)
            }
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = VaultCard(attributes: attributes)
            self.paymentSource = VaultCardPaymentSource(card: card)
        }
    }
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
