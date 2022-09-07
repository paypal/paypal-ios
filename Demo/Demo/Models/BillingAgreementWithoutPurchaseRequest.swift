struct BillingAgreementWithoutPurchaseRequest: Codable {

    let descrption: String
    let shippingAddress: ShippingAddress
    let payer: Payer
    let plan: Plan
}

struct ShippingAddress: Codable {

    let line1: String
    let city: String
    let state: String
    let postalCode: String
    let countryCode: String
    let recipientName: String
}

struct Payer: Codable {

    let paymentMethod: String
}

struct Plan: Codable {

    let type: String
    let merchantPreferences: MerchantPreferences
}

struct MerchantPreferences: Codable {

    let returnUrl: String
    let cancelUrl: String
    let notifyUrl: String
    let acceptedPymtType: String
    let skipShippingAddress: Bool
    let immutableShippingAddress: Bool
}
