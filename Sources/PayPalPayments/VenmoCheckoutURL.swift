import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Checkout page the PayPal JS SDK uses for Venmo (`/smart/checkout/venmo/popup`).
enum VenmoCheckoutURL {

    static let path = "/smart/checkout/venmo/popup"

    static func make(environment: CoreEnvironment, clientID: String, orderID: String) -> URL? {
        guard var components = URLComponents(url: environment.payPalBaseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "token", value: orderID),
            URLQueryItem(name: "client-id", value: clientID),
            URLQueryItem(name: "fundingSource", value: PayPalCheckoutFundingSource.venmo.rawValue)
        ]
        return components.url
    }
}
