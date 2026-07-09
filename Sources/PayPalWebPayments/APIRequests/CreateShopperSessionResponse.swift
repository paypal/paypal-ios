import Foundation

struct CreateShopperSessionResponse: Decodable {

    let external: ExternalNode?
    let shopperSession: ShopperSessionResult?

    enum CodingKeys: String, CodingKey {
        case external
        case shopperSession = "createShopperSessionWithAppSwitchEligibility"
    }

    var resolvedShopperSession: ShopperSessionResult? {
        external?.shopperSession ?? shopperSession
    }
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

    /// Reason the session is ineligible for app-switch (nil when eligible).
    let ineligibleReason: String?

    /// Authentication methods matched for the buyer's identity.
    let matchedAuthenticationMethods: [String]?

    /// The pre-warmed Shopper Session config.
    let shopperSessionConfig: ShopperSessionConfig?

    init(
        appSwitchEligible: Bool,
        redirectURL: String?,
        ineligibleReason: String?,
        matchedAuthenticationMethods: [String]?,
        shopperSessionConfig: ShopperSessionConfig?
    ) {
        self.appSwitchEligible = appSwitchEligible
        self.redirectURL = redirectURL
        self.ineligibleReason = ineligibleReason
        self.matchedAuthenticationMethods = matchedAuthenticationMethods
        self.shopperSessionConfig = shopperSessionConfig
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.appSwitchEligibilityResponse) {
            let eligibility = try container.decode(AppSwitchEligibilityResponse.self, forKey: .appSwitchEligibilityResponse)
            appSwitchEligible = eligibility.appSwitchEligible
            redirectURL = eligibility.redirectURL
            ineligibleReason = eligibility.ineligibleReason
            matchedAuthenticationMethods = nil
            shopperSessionConfig = try container.decodeIfPresent(ShopperSessionResponse.self, forKey: .shopperSessionResponse)
                .map { ShopperSessionConfig(id: $0.sessionId, expiresAt: $0.expiresAt) }
            return
        }

        appSwitchEligible = try container.decodeIfPresent(Bool.self, forKey: .appSwitchEligible) ?? false
        redirectURL = try container.decodeIfPresent(String.self, forKey: .redirectURL)
        ineligibleReason = try container.decodeIfPresent(String.self, forKey: .ineligibleReason)
        matchedAuthenticationMethods = try container.decodeIfPresent([String].self, forKey: .matchedAuthenticationMethods)
        shopperSessionConfig = try container.decodeIfPresent(ShopperSessionConfig.self, forKey: .shopperSessionConfig)
    }

    enum CodingKeys: String, CodingKey {
        case appSwitchEligible
        case redirectURL
        case ineligibleReason
        case matchedAuthenticationMethods
        case shopperSessionConfig
        case appSwitchEligibilityResponse
        case shopperSessionResponse
    }

    struct ShopperSessionConfig: Decodable {

        /// Opaque Shopper Session identifier.
        let id: String
        /// ISO-8601 expiry timestamp.
        let expiresAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case sessionId
            case expiresAt
        }

        init(id: String, expiresAt: String) {
            self.id = id
            self.expiresAt = expiresAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let id = try container.decodeIfPresent(String.self, forKey: .id) {
                self.id = id
            } else {
                self.id = try container.decode(String.self, forKey: .sessionId)
            }
            expiresAt = try container.decode(String.self, forKey: .expiresAt)
        }
    }
}

private struct AppSwitchEligibilityResponse: Decodable {

    let appSwitchEligible: Bool
    let ineligibleReason: String?
    let redirectURL: String?
}

private struct ShopperSessionResponse: Decodable {

    let sessionId: String
    let expiresAt: String
}
