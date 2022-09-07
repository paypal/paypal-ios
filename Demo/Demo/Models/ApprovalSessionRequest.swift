struct ApprovalSessionRequest: Codable {

    let customerId: String
    let source: Source
    let applicationContext: ApplicationContext
}

struct Source: Codable {

    let paypal: PayPalSource
}

struct PayPalSource: Codable {

    let usageType: String
    let customerType: String
}
