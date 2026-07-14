import Foundation
import CorePayments
import PayPalWebPayments

/// Shared app-switch return/cancel/fallback URL configuration for Shopper Session creation.
/// Used by both the PayPalWeb and Vault flows so the callback URLs stay in sync.
enum ShopperSessionURLConfigFactory {

    static let urlConfig: PayPalURLConfig = {
        let checkoutPath = "x-callback-url/paypal-sdk/paypal-checkout"
        let scheme = PayPalCoreConstants.callbackURLScheme

        guard let returnAppURL = URL(string: "\(scheme)://\(checkoutPath)"),
              let cancelAppURL = URL(string: "\(scheme)://\(checkoutPath)/cancel") else {
            fatalError("Failed to construct Shopper Session callback URLs for scheme: \(scheme)")
        }

        return PayPalURLConfig(
            returnAppURL: returnAppURL,
            cancelAppURL: cancelAppURL,
            fallbackSchemeURL: URL(string: scheme)
        )
    }()
}
