struct CreateOrderParams: Encodable {

    let applicationContext: ApplicationContext?
    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var paymentSource: VaultCardPaymentSource?
}

struct ApplicationContext: Codable {

    let userAction: String
    let shippingPreference: String

    enum CodingKeys: String, CodingKey {
        case userAction
        case shippingPreference
    }
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

    var shipping: Shipping?
    var payee: Payee?
    let amount: Amount
}

struct Shipping: Encodable {

    let address: Address
    let name: Name
    let options: [ShippingOption]?

    struct Address: Encodable {

        let addressLine1: String
        let addressLine2: String
        let adminArea2: String
        let adminArea1: String
        let countryCode: String
        let postalCode: String

        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case adminArea2 = "admin_area_2"
            case adminArea1 = "admin_area_1"
            case addressLine1 = "address_line_1"
            case addressLine2 = "address_line_2"
            case countryCode
            case postalCode
        }
    }

    struct Name: Encodable {

        let fullName: String
    }
}

struct ShippingOption: Encodable {

    let selected: Bool
    let id: String
    let amount: ItemTotal
    let label: String
    let type: String
}
struct Payee: Encodable {

    let merchantID: String
    let emailAddress: String
}

struct Amount: Encodable {

    let currencyCode: String
    let value: String
    var breakdown: Breakdown?
    
    struct Breakdown: Encodable {

        let shipping: ItemTotal
        let itemTotal: ItemTotal
    }
}

struct ItemTotal: Encodable {

    let value: String
    let currencyValue: String?
    let currencyCode: String?
}
