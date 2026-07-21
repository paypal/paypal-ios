import Foundation

struct CreateShopperSessionResponse: Decodable {

    let external: ExternalContainer?

    var shopperSession: ShopperSessionResult? {
        external?.shopperSession
    }
}

struct ExternalContainer: Decodable {

    let shopperSession: ShopperSessionResult?

    enum CodingKeys: String, CodingKey {
        case shopperSession = "createShopperSessionWithAppSwitchEligibility"
    }
}

/// The payload returned by `createShopperSessionWithAppSwitchEligibility`.
struct ShopperSessionResult: Decodable {

    let appSwitchEligibilityResponse: AppSwitchEligibilityResponse?
    let shopperSessionResponse: ShopperSessionResponse?

    init(
        appSwitchEligible: Bool,
        redirectURL: String?,
        ineligibleReason: String?,
        matchedAuthenticationMethods: [String]?,
        shopperSessionConfig: ShopperSessionConfig?
    ) {
        self.appSwitchEligibilityResponse = AppSwitchEligibilityResponse(
            appSwitchEligible: appSwitchEligible,
            ineligibleReason: ineligibleReason,
            checkoutUrls: redirectURL.map { CheckoutUrls(redirectURL: $0, checkoutFallbackUrl: nil) }
        )
        self.shopperSessionResponse = shopperSessionConfig.map {
            ShopperSessionResponse(sessionId: $0.id, expiresAt: $0.expiresAt)
        }
    }

    // MARK: - Convenience accessors (preserve existing call sites in PayPalWebCheckoutClient)

    var appSwitchEligible: Bool {
        appSwitchEligibilityResponse?.appSwitchEligible ?? false
    }

    var redirectURL: String? {
        appSwitchEligibilityResponse?.checkoutUrls?.redirectURL
    }

    var checkoutFallbackURL: String? {
        appSwitchEligibilityResponse?.checkoutUrls?.checkoutFallbackUrl
    }

    var ineligibleReason: String? {
        appSwitchEligibilityResponse?.ineligibleReason
    }

    var matchedAuthenticationMethods: [String]? = []

    var shopperSessionConfig: ShopperSessionConfig? {
        shopperSessionResponse.map { ShopperSessionConfig(id: $0.sessionId, expiresAt: $0.expiresAt) }
    }
}

struct AppSwitchEligibilityResponse: Decodable {

    let appSwitchEligible: Bool
    let ineligibleReason: String?
    let checkoutUrls: CheckoutUrls?
}

struct CheckoutUrls: Decodable {

    let redirectURL: String?
    let checkoutFallbackUrl: String?
}

struct ShopperSessionResponse: Decodable {

    let sessionId: String
    let expiresAt: String?
}

struct ShopperSessionConfig {

    let id: String
    let expiresAt: String?
}
