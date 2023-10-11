struct CreateOrderParams: Codable {

    let applicationContext: ApplicationContext?
    let intent: String
    var purchaseUnits: [PurchaseUnit]?
}

struct ApplicationContext: Codable {
    
    let userAction: String
    let shippingPreference: String

    enum CodingKeys: String, CodingKey {
        case userAction
        case shippingPreference
    }
}

struct PurchaseUnit: Codable {

    var shipping: Shipping?
    var payee: Payee?
    let amount: Amount
}

struct Shipping: Codable {
    
    let address: Address
    let name: Name
    
    struct Address: Codable {
        
        let addressLine1: String
        let addressLine2: String
        let adminArea2: String
        let adminArea1: String
        let countryCode: String
        let postalCode: String
        
        enum CodingKeys: String, CodingKey {
            case adminArea2 = "admin_area_2"
            case adminArea1 = "admin_area_1"
            case addressLine1 = "address_line_1"
            case addressLine2 = "address_line_2"
            case countryCode
            case postalCode
        }
    }
    
    struct Name: Codable {
        
        let fullName: String
    }
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
    var breakdown: Breakdown?
    
    struct Breakdown: Codable {
        
        let shipping: String
        let itemTotal: ItemTotal
    }
    
    struct ItemTotal: Codable {
        
        let value: String
        let currencyValue: String
        let currencyCode: String
    }
}

struct Payee: Codable {
    
    let merchantID: String
    let emailAddress: String
}
