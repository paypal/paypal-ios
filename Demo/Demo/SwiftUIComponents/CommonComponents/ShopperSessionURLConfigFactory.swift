import Foundation
import CorePayments
import PayPalWebPayments

/// Shared app-switch return/cancel/fallback URL configuration for Shopper Session creation.
/// Used by both the PayPalWeb and Vault flows so the callback URLs stay in sync.
enum ShopperSessionURLConfigFactory {

    static let urlConfig: PayPalURLConfig = {
        let checkoutPath = "https://ppcp-mobile-demo-sandbox-87bbd7f0a27f.herokuapp.com"
        let scheme = PayPalCoreConstants.callbackURLScheme

        guard let returnAppURL = URL(string: "\(checkoutPath)/paypal-return"),
              let cancelAppURL = URL(string: "\(checkoutPath)/paypal-cancel") else {
            fatalError("Failed to construct Shopper Session callback URLs for scheme: \(scheme)")
        }

        return PayPalURLConfig(
            returnAppURL: returnAppURL,
            cancelAppURL: cancelAppURL,
            fallbackSchemeURL: URL(string: scheme)
        )
    }()
}
