import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

extension PayPalCheckoutAnalyticsData {

    convenience init(
        userIdentity: PayPalUserIdentity?,
        urlConfig: PayPalURLConfig,
        userAction: PayPalUserAction = .continue
    ) {
        self.init()
        isCachedSession = userIdentity?.existingPayPalSessionID != nil

        self.userAction = userAction.title
        returnAppURL = urlConfig.returnAppURL
        cancelAppURL = urlConfig.cancelAppURL
        fallbackSchemeURL = urlConfig.fallbackSchemeURL
        
        paypalNativeAppInstalled = UIApplication.shared.isOsloAppInstalled()
    }

    /// Populates the fields derived from the Shopper Session fetch response, once it succeeds.
    func update(with shopperSession: ShopperSessionResult, isVault: Bool) {
        shopperSessionID = shopperSession.shopperSessionConfig?.id
        shopperSessionExpiration = shopperSession.shopperSessionConfig?.expiresAt
        appSwitchEligible = shopperSession.appSwitchEligible
        ineligibleReason = shopperSession.ineligibleReason
        if let redirectURL = shopperSession.redirectURL {
            appSwitchURL = URL(string: redirectURL)
        }
        fallbackUrl = shopperSession.checkoutFallbackURL
        isVaultRequest = isVault
    }
}
