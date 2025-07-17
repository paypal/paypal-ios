import Foundation

struct CreateSetupTokenParam: Encodable {

    let customer: VaultCustomer?
    let paymentSource: PaymentSourceType

    enum CodingKeys: String, CodingKey {
        case paymentSource
        case customer
    }
}

struct VaultExperienceContext: Encodable {

    let returnUrl = "sdk.ios.paypal://vault/success"
    let cancelUrl = "sdk.ios.paypal://vault/cancel"
}

struct PayPal: Encodable {

    var usageType: String
    let experienceContext = VaultExperienceContext()
}

struct SetupTokenCard: Encodable {

    let experienceContext = VaultExperienceContext()
    let verificationMethod: String?
}

enum PaymentSourceType: Encodable {
    case card(verification: String?)
    case paypal(usageType: String)

    private enum CodingKeys: String, CodingKey {
        case card, paypal
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .card(let verification):
            try container.encode(SetupTokenCard(verificationMethod: verification), forKey: .card)
        case .paypal(let usageType):
            try container.encode(PayPal(usageType: usageType), forKey: .paypal)
        }
    }
}

struct VaultCustomer: Encodable {

    var id: String?

    private enum CodingKeys: String, CodingKey {
        case id
    }
}
