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

    var appSwitchContext: AppSwitchContext?
    var returnUrl: String
    var cancelUrl: String

    init(appSwitchContext: AppSwitchContext? = nil) {
        self.appSwitchContext = appSwitchContext
        // When app switching, derive the callbacks from the same host we advertise as `appUrl`, so
        // the two can never drift. That host must be declared in Demo.entitlements and listed in
        // the domain's apple-app-site-association file for the universal link to resolve.
        if let appURL = appSwitchContext?.nativeApp.appUrl {
            self.returnUrl = appURL + "/success"
            self.cancelUrl = appURL + "/cancel"
        } else {
            self.returnUrl = "sdk.ios.paypal://vault/success"
            self.cancelUrl = "sdk.ios.paypal://vault/cancel"
        }
    }
}

struct PayPal: Encodable {

    var usageType: String
    let experienceContext: VaultExperienceContext
}

struct SetupTokenCard: Encodable {

    let experienceContext: VaultExperienceContext
    let verificationMethod: String?

    init(verificationMethod: String?, experienceContext: VaultExperienceContext) {
        self.verificationMethod = verificationMethod
        self.experienceContext = experienceContext
    }
}

enum PaymentSourceType: Encodable {
    case card(verification: String?, experienceContext: VaultExperienceContext)
    case paypal(usageType: String, experienceContext: VaultExperienceContext)

    private enum CodingKeys: String, CodingKey {
        case card, paypal
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .card(verification, experienceContext):
            try container.encode(SetupTokenCard(verificationMethod: verification, experienceContext: experienceContext), forKey: .card)
        case let .paypal(usageType, experienceContext):
            try container.encode(PayPal(usageType: usageType, experienceContext: experienceContext), forKey: .paypal)
        }
    }
}

struct VaultCustomer: Encodable {

    var id: String?

    private enum CodingKeys: String, CodingKey {
        case id
    }
}
