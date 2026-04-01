struct CreateOrderParams: Encodable {

    var applicationContext: ApplicationContext?
    var intent: String
    var purchaseUnits: [PurchaseUnit]
    var paymentSource: OrderPaymentSource?
}

struct ApplicationContext: Codable {

    let userAction: String
    let shippingPreference: String
}

// MARK: - Payment source (general, for both vault, and non-vault)

enum OrderPaymentSource: Encodable {

    case paypal(OrderPayPalPaymentSource)
    case card(OrderCardPaymentSource)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .paypal(let source): try container.encode(source)
        case .card(let source):   try container.encode(source)
        }
    }
}

struct OrderPayPalPaymentSource: Encodable {

    let paypal: PayPalSource
}

struct OrderCardPaymentSource: Encodable {

    let card: CardSource
}

// Attributes are only for vault now
struct PayPalSource: Encodable {

    var attributes: Attributes?
    var experienceContext: PayPalExperienceContext?
}

struct CardSource: Encodable {

    var attributes: Attributes?
}

// MARK: - PayPal experience context

struct PayPalExperienceContext: Encodable {

    let returnUrl: String
    let cancelUrl: String
    var appSwitchContext: AppSwitchContext?
}

struct AppSwitchContext: Encodable {

    let nativeApp: NativeApp
    init(appUrl: String, osType: String = "IOS") {
        self.nativeApp = NativeApp(osType: osType, appUrl: appUrl)
    }
}

struct NativeApp: Encodable {

    let osType: String
    let appUrl: String
}

// MARK: - Vault attributes

struct Attributes: Encodable {

    let vault: Vault
    let customer: Customer?
    init(vault: Vault, customer: Customer? = nil) {
        self.vault = vault
        self.customer = customer
    }
}

struct Vault: Encodable {

    let storeInVault: String
    let usageType: String?
    let customerType: String?
    init(storeInVault: String, usageType: String? = nil, customerType: String? = nil) {
        self.storeInVault = storeInVault
        self.usageType = usageType
        self.customerType = customerType
    }
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
