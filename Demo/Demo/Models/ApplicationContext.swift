struct ApplicationContext: Codable {

    var returnUrl: String?
    var cancelUrl: String?
    var locale: String?
    var paymentMethodPreference: PaymentMethodPreference?
    var shippingPreference: String?
}

struct PaymentMethodPreference: Codable {

    let payePreferred: String
    let payerSelected: String
}
