import Foundation
import CorePayments
import PayPalPayments

/// Shared app-switch return/cancel/fallback URL configuration for Shopper Session creation.
/// Used by both the PayPalWeb and Vault flows so the callback URLs stay in sync.
enum ShopperSessionURLConfigFactory {

    enum ConfigurationError: LocalizedError {
        case invalidCallbackURL(String)

        var errorDescription: String? {
            switch self {
            case .invalidCallbackURL(let baseReturnUrl):
                return "Failed to construct Shopper Session callback URLs for base return URL: \(baseReturnUrl)"
            }
        }
    }

    static func makeURLConfig() throws -> PayPalURLConfig {
        let baseReturnUrl = DemoSettings.environment.baseURL
        guard var returnAppURLComponents = URLComponents(string: "\(baseReturnUrl)/success"),
              let cancelAppURL = URL(string: "\(baseReturnUrl)/cancel") else {
            throw ConfigurationError.invalidCallbackURL(baseReturnUrl)
        }

        returnAppURLComponents.queryItems = (returnAppURLComponents.queryItems ?? []) + [
            URLQueryItem(name: "platform", value: "iOS")
        ]

        guard let returnAppURL = returnAppURLComponents.url else {
            throw ConfigurationError.invalidCallbackURL(baseReturnUrl)
        }

        let checkoutPath = "x-callback-url/paypal-sdk/paypal-checkout"
        let scheme = PayPalCoreConstants.callbackURLScheme

        return PayPalURLConfig(
            returnAppURL: returnAppURL,
            cancelAppURL: cancelAppURL,
            fallbackSchemeURL: URL(string: "\(scheme)://\(checkoutPath)")
        )
    }
}
