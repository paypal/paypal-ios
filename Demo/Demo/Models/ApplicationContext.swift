struct ApplicationContext: Codable {

    var returnUrl: String?
    var cancelUrl: String?
    var locale: String?
    var paymentMethodPreference: PaymentMethodPreference?
}

struct PaymentMethodPreference: Codable {

    let payePreferred: String
    let payerSelected: String
}
