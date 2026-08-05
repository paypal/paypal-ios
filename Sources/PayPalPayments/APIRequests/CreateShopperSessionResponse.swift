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
