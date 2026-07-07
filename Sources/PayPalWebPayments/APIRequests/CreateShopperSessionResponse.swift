import Foundation

struct CreateShopperSessionResponse: Decodable {

    let external: ExternalNode?
}

struct ExternalNode: Decodable {

    let shopperSession: ShopperSessionResult?

    enum CodingKeys: String, CodingKey {
        case shopperSession = "createShopperSessionWithAppSwitchEligibility"
    }
}

/// The payload returned by `createShopperSessionWithAppSwitchEligibility`.
struct ShopperSessionResult: Decodable {

    /// Whether the buyer's device is eligible for PayPal app-switch.
    let appSwitchEligible: Bool

    /// The app-switch redirect URL to open when eligible.
    let redirectURL: String?

    /// Fallback web checkout URL if app-switch is unavailable.
    let checkoutFallbackUrl: String?

    /// Reason the session is ineligible for app-switch (nil when eligible).
    let ineligibleReason: String?

    /// Authentication methods matched for the buyer's identity.
    let matchedAuthenticationMethods: [String]?

    /// The pre-warmed Shopper Session config.
    let shopperSessionConfig: ShopperSessionConfig?

    struct ShopperSessionConfig: Decodable {

        /// Opaque Shopper Session identifier.
        let id: String
        /// ISO-8601 expiry timestamp.
        let expiresAt: String
    }
}
