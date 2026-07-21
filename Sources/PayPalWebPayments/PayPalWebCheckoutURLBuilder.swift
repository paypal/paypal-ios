import Foundation

/// Builds the deep-link URLs used to app-switch into the PayPal app for checkout and vault flows.
struct PayPalWebCheckoutURLBuilder {

    private enum FlowType: String {
        case checkout = "ecs"
        case vault = "va"
    }

    private let base: String

    init(base: String) {
        self.base = base
    }

    /// Builds the app-switch URL for the checkout (one-time payment) flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    func checkoutAppSwitchURL(
        clientID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        orderID: String,
        sessionID: String?
    ) -> URL? {
        makeAppSwitchURL(
            merchantID: clientID,
            flowType: .checkout,
            fundingSource: fundingSource,
            sessionID: sessionID,
            tokenItem: URLQueryItem(name: "token", value: orderID)
        )
    }

    /// Builds the app-switch URL for the vault-without-purchase flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    func vaultAppSwitchURL(
        merchantID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        sessionID: String?,
        setupTokenID: String
    ) -> URL? {
        makeAppSwitchURL(
            merchantID: merchantID,
            flowType: .vault,
            fundingSource: fundingSource,
            sessionID: sessionID,
            tokenItem: URLQueryItem(name: "approval_session_id", value: setupTokenID)
        )
    }

    /// Shared query construction for both flows. Query item values are percent-encoded by
    /// `URLComponents` (rather than interpolated directly into a string), and any query already
    /// present on `base` is preserved instead of being overwritten by a second `?`.
    private func makeAppSwitchURL(
        merchantID: String,
        flowType: FlowType,
        fundingSource: PayPalWebCheckoutFundingSource,
        sessionID: String?,
        tokenItem: URLQueryItem
    ) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }

        // Drop malformed items (e.g. from a "&&" in `base`), which `URLComponents`
        // parses as an empty-name, nil-value query item.
        var queryItems = (components.queryItems ?? []).filter { !$0.name.isEmpty }
        var additionalQueryItems: [URLQueryItem] = [
            tokenItem,
            URLQueryItem(name: "source", value: "pda"),
            URLQueryItem(name: "merchant", value: merchantID),
            URLQueryItem(name: "flow_type", value: flowType.rawValue),
            URLQueryItem(name: "funding_source", value: fundingSource.rawValue),
            URLQueryItem(name: "switch_initiated_time", value: String(Int(round(Date().timeIntervalSince1970 * 1000))))
        ]
        if let sessionID = sessionID {
            additionalQueryItems.append(URLQueryItem(name: "shopperSessionId", value: sessionID))
        }
        queryItems.append(contentsOf: additionalQueryItems)
        components.queryItems = queryItems

        return components.url
    }
}
