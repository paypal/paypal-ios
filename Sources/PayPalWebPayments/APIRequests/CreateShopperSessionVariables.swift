import Foundation

struct CreateShopperSessionVariables: Encodable {

    let returnUrl: String
    let cancelUrl: String
    let fallbackSchemeUrl: String?
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
        switch identity {
        case .serverSideShopperSession(let id):
            serverSideShopperSessionId = id
            email = nil
            phone = nil
        case let .emailPhone(email, phone):
            serverSideShopperSessionId = nil
            self.email = email
            self.phone = phone
        case .none:
            serverSideShopperSessionId = nil
            email = nil
            phone = nil
        }
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
