import Foundation

struct CreateShopperSessionVariables: Encodable {

    let returnURL: URL
    let cancelURL: URL
    let fallbackSchemeURL: URL?
    let userAction: String
    let osType: String
    let integrationArtifact: String
    let integrationChannel: String?
    let userIdentity: UserIdentityVariables?

    /// Keeps the wire format (`returnUrl`/`cancelUrl`/`fallbackSchemeUrl`) matching the GraphQL
    /// variable names, independent of the Swift-side `URL` acronym casing.
    enum CodingKeys: String, CodingKey {
        case returnURL = "returnUrl"
        case cancelURL = "cancelUrl"
        case fallbackSchemeURL = "fallbackSchemeUrl"
        case userAction
        case osType
        case integrationArtifact
        case integrationChannel
        case userIdentity
    }
}

struct UserIdentityVariables: Encodable {

    let serverSideShopperSessionId: String?
    let email: String?
    let phone: String?

    init(from identity: PayPalUserIdentity) {
        serverSideShopperSessionId = identity.existingPayPalSessionID
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
