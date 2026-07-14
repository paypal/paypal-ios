import Foundation

struct CreateShopperSessionVariables: Encodable {

    // MARK: - Required
    let appSwitchEligibilityInput: AppSwitchEligibilityInput
    let shopperSessionInput: ShopperSessionInput
}

struct AppSwitchEligibilityInput: Encodable {

    // MARK: - Optional — derived internally
    let contextId: String
    let tokenType: String
    let osType: String
    let merchantOptInForAppSwitch: Bool
    let paypalNativeAppInstalled: Bool
    let experimentationContext: ExperimentationContext

    let buyerEmailAddressMerchantPassed: String?
}
struct ExperimentationContext: Encodable {

    let appSwitchSupported: Bool
    let merchantCountry: String
    let integrationChannel: String
    let isWebLLSEligible: Bool
    let isWebView: Bool
    let paymentType: String
    let buyerGUID: String?
    let merchantAccountId: String?

    enum CodingKeys: String, CodingKey {
        case appSwitchSupported, merchantCountry, integrationChannel
        case isWebLLSEligible, isWebView, paymentType, buyerGUID, merchantAccountId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appSwitchSupported, forKey: .appSwitchSupported)
        try container.encode(merchantCountry, forKey: .merchantCountry)
        try container.encode(integrationChannel, forKey: .integrationChannel)
        try container.encode(isWebLLSEligible, forKey: .isWebLLSEligible)
        try container.encode(isWebView, forKey: .isWebView)
        try container.encode(paymentType, forKey: .paymentType)
        // Encode as explicit JSON `null` when nil (matches Android) instead of omitting the key.
        try container.encode(buyerGUID, forKey: .buyerGUID)
        try container.encode(merchantAccountId, forKey: .merchantAccountId)
    }
}

    // MARK: - Optional — not currently wired
struct ShopperSessionInput: Encodable {

    let returnAppUrl: String
    let cancelAppUrl: String
    let sdkVersion: String
    let fallbackUrlScheme: String?
    let phone: PhoneInput?

    enum CodingKeys: String, CodingKey {
        case returnAppUrl, cancelAppUrl, sdkVersion, fallbackUrlScheme, phone
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(returnAppUrl, forKey: .returnAppUrl)
        try container.encode(cancelAppUrl, forKey: .cancelAppUrl)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        try container.encodeIfPresent(fallbackUrlScheme, forKey: .fallbackUrlScheme)
        // Encode as explicit JSON `null` when nil (matches Android) instead of omitting the key.
        try container.encode(phone, forKey: .phone)
    }
}

struct PhoneInput: Encodable {

    let countryCode: String
    let nationalNumber: String
}
