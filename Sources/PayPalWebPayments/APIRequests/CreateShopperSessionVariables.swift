import Foundation

struct CreateShopperSessionVariables: Encodable {

    let returnUrl: URL
    let cancelUrl: URL
    let fallbackSchemeUrl: URL
    let userAction: String
    let osType: String
    let integrationArtifact: String
    let integrationChannel: String?
    let userIdentity: UserIdentityVariables?
}

struct UserIdentityVariables: Encodable {

    let serverSideShopperSessionId: String?
    let email: String?
    let phone: String?

    init(from identity: PayPalUserIdentity) {
        serverSideShopperSessionId = identity.shopperSessionID
        email = identity.email
        phone = identity.phone
    }
}

extension PayPalUserAction {

    var graphQLValue: String {
        switch self {
        case .continue: return "CONTINUE"
        case .payNow: return "PAY_NOW"
        case .setupNow: return "SETUP_NOW"
        }
    }
}
