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
            tokenName: "token",
            token: orderID,
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
            tokenName: "approval_session_id",
            token: setupTokenID,
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
        tokenName: String,
        token: String,
        flowType: FlowType,
        clientID: String,
        sessionID: String
    ) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: tokenName, value: token))
        queryItems.append(URLQueryItem(name: "source", value: "pda"))
        queryItems.append(URLQueryItem(name: "merchant", value: clientID))
        queryItems.append(URLQueryItem(name: "flow_type", value: flowType.rawValue))
        queryItems.append(URLQueryItem(name: "sessionID", value: sessionID))
        components.queryItems = queryItems

        return components.url
    }
}
