import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

enum ShopperSessionGraphQLQueries {

    static let createShopperSessionWithAppSwitchEligibility = """
        mutation CreateShopperSessionWithAppSwitchEligibility(
            $input: CreateShopperSessionWithAppSwitchEligibilityInput!
        ) {
            createShopperSessionWithAppSwitchEligibility(input: $input) {
                sessionId
                expiresAt
                checkoutUrls {
                    appCheckout
                    webCheckoutWeb
                    appApprovalUrl
                    webApprovalUrl
                }
                paymentMethodConfig {
                    ssidRouting
                    appSwitchEligible
                }
            }
        }
        """
}

struct UserIdentityInput: Encodable {
    let serverSideShopperSessionId: String?
    let email: String?
    let phone: String?
}

struct URLConfigInput: Encodable {
    let returnAppUrl: String
    let cancelAppUrl: String
    let fallbackSchemeUrl: String?
}

struct CreateShopperSessionWithAppSwitchEligibilityInput: Encodable {
    let clientID: String
    let merchantID: String
    let bnCode: String?
    let sdkVersion: String
    let osVersion: String
    let platform: String
    let integrationType: String
    let paymentMethod: String
    let flowType: String
    let paypalAppInstalled: Bool
    let venmoAppInstalled: Bool
    let userIdentity: UserIdentityInput?
    let urlConfig: URLConfigInput
    let userAction: String
}

struct CreateShopperSessionGraphQLVariables: Encodable {
    let input: CreateShopperSessionWithAppSwitchEligibilityInput
}

struct CreateShopperSessionResponse: Decodable {
    let createShopperSessionWithAppSwitchEligibility: ShopperSessionWithAppSwitchEligibility?
}

struct ShopperSessionWithAppSwitchEligibility: Decodable {
    let sessionId: String?
    let expiresAt: String?
    let checkoutUrls: CheckoutUrls?
    let paymentMethodConfig: PaymentMethodConfig?
}

struct CheckoutUrls: Decodable {
    let appCheckout: String?
    let webCheckoutWeb: String?
    let appApprovalUrl: String?
    let webApprovalUrl: String?
}

struct PaymentMethodConfig: Decodable {
    let ssidRouting: Bool?
    let appSwitchEligible: Bool?
}

enum PayPalUserActionGraphQL {

    static func checkoutValue(for action: PayPalUserAction) throws -> String {
        switch action {
        case .payNow:
            return "commit"
        case .continue:
            return "continue"
        case .setupNow:
            throw PayPalError.invalidUserActionError
        }
    }

    static func vaultValue(for action: PayPalUserAction) -> String {
        switch action {
        case .setupNow:
            return "setup_now"
        case .continue, .payNow:
            return "continue"
        }
    }
}

extension UserIdentityInput {

    init?(identity: PayPalUserIdentity?) {
        guard let identity else { return nil }
        self.init(
            serverSideShopperSessionId: identity.serverSideShopperSessionId,
            email: identity.email,
            phone: identity.phone
        )
    }
}

extension URLConfigInput {

    init(urlConfig: PayPalURLConfig) {
        self.init(
            returnAppUrl: urlConfig.returnAppUrl,
            cancelAppUrl: urlConfig.cancelAppUrl,
            fallbackSchemeUrl: urlConfig.fallbackSchemeUrl
        )
    }
}

extension CreateShopperSessionWithAppSwitchEligibilityInput {

    static func make(
        config: CoreConfig,
        sdkVersion: String,
        osVersion: String,
        paymentMethod: String,
        flowType: String,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool,
        userIdentity: PayPalUserIdentity?,
        urlConfig: PayPalURLConfig,
        userAction: String
    ) -> CreateShopperSessionWithAppSwitchEligibilityInput {
        CreateShopperSessionWithAppSwitchEligibilityInput(
            clientID: config.clientID,
            merchantID: config.merchantID,
            bnCode: config.bnCode,
            sdkVersion: sdkVersion,
            osVersion: osVersion,
            platform: PayPalCoreConstants.platform,
            integrationType: PayPalCoreConstants.integrationType,
            paymentMethod: paymentMethod,
            flowType: flowType,
            paypalAppInstalled: paypalAppInstalled,
            venmoAppInstalled: venmoAppInstalled,
            userIdentity: UserIdentityInput(identity: userIdentity),
            urlConfig: URLConfigInput(urlConfig: urlConfig),
            userAction: userAction
        )
    }
}
