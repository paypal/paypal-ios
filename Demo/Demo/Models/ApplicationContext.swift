struct ApplicationContext: Codable {

    var returnUrl: String?
    var cancelUrl: String?
    var locale: String?
    var paymentMethodPreference: PaymentMethodPreference?
    var shippingPreference: String?
    var userAction: String?
    var landingPage: String?
    var brandName: String?
}

struct PaymentMethodPreference: Codable {

    let payeePreferred: String
    let payerSelected: String
}
