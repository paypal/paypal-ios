import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

extension PayPalCheckoutAnalyticsData {

    convenience init(
        tokenType: TokenType,
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
        
        paypalNativeAppInstalled = nil
        isVaultRequest = tokenType == .vaultID
    }

    /// Populates the fields derived from the Shopper Session fetch response, once it succeeds.
    /// Does not set `appSwitchURL`/`browserSwitchURL` here: those are only known once the flow commits
    /// to an app switch or browser fallback attempt (see `attemptSessionAppSwitch`/`startWebCheckoutFlow`/
    /// `startVaultWebAuthFlow` in `PayPalClient`).
    func update(with shopperSession: ShopperSessionResult) {
        shopperSessionID = shopperSession.shopperSessionConfig?.id
        shopperSessionExpiration = shopperSession.shopperSessionConfig?.expiresAt
        appSwitchEligible = shopperSession.appSwitchEligible
        ineligibleReason = shopperSession.ineligibleReason
        fallbackUrl = shopperSession.checkoutFallbackURL
    }
}
