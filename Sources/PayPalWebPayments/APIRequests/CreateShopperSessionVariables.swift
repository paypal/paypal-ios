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
}

    // MARK: - Optional — not currently wired
struct ShopperSessionInput: Encodable {

    let returnAppUrl: String
    let cancelAppUrl: String
    let sdkVersion: String
    let fallbackUrlScheme: String?
}
