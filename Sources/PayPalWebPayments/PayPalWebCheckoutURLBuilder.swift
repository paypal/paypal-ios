import Foundation

/// Builds the deep-link URLs used to app-switch into the PayPal app for checkout and vault flows.
enum PayPalWebCheckoutURLBuilder {

    private enum FlowType: String {
        case checkout = "ecs"
        case vault = "va"
    }

    /// Builds the app-switch URL for the checkout (one-time payment) flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    static func checkoutAppSwitchURL(
        base: String,
        orderID: String,
        clientID: String,
        sessionID: String
    ) -> URL? {
        makeAppSwitchURL(
            base: base,
            tokenItem: URLQueryItem(name: "token", value: orderID),
            flowType: .checkout,
            clientID: clientID,
            sessionID: sessionID
        )
    }

    /// Builds the app-switch URL for the vault-without-purchase flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    static func vaultAppSwitchURL(
        base: String,
        setupTokenID: String,
        clientID: String,
        sessionID: String
    ) -> URL? {
        makeAppSwitchURL(
            base: base,
            tokenItem: URLQueryItem(name: "approval_session_id", value: setupTokenID),
            flowType: .vault,
            clientID: clientID,
            sessionID: sessionID
        )
    }

    /// Shared query construction for both flows. Query item values are percent-encoded by
    /// `URLComponents` (rather than interpolated directly into a string), and any query already
    /// present on `base` is preserved instead of being overwritten by a second `?`.
    private static func makeAppSwitchURL(
        base: String,
        tokenItem: URLQueryItem,
        flowType: FlowType,
        clientID: String,
        sessionID: String
    ) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }

        var queryItems = (components.queryItems ?? []).filter { !$0.name.isEmpty }
        let additionalQueryItems: [URLQueryItem] = [
            tokenItem,
            URLQueryItem(name: "source", value: "pda"),
            URLQueryItem(name: "merchant", value: clientID),
            URLQueryItem(name: "flow_type", value: flowType.rawValue),
            URLQueryItem(name: "shopperSessionId", value: sessionID),
            URLQueryItem(name: "switch_initiated_time", value: String(Int(round(Date().timeIntervalSince1970 * 1000))))
        ]
        queryItems.append(contentsOf: additionalQueryItems)
        components.queryItems = queryItems

        return components.url
    }
}
