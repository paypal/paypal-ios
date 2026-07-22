import Foundation

/// Builds the deep-link URLs used to app-switch into the PayPal app for checkout and vault flows.
struct PayPalWebCheckoutURLBuilder {

    private enum FlowType: String {
        case checkout = "ecs"
        case vault = "va"
    }

    static func tokenQueryParameterName(for tokenType: TokenType) -> String {
        switch tokenType {
        case .orderID: return "token"
        case .vaultID: return "approval_session_id"
        case .billingToken: return "token"
        }
    }

    private let base: String

    init(base: String) {
        self.base = base
    }

    /// Builds the app-switch URL for the checkout (one-time payment) flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    func makeAppSwitchURL(
        clientID: String,
        fundingSource: PayPalWebCheckoutFundingSource,
        token: String,
        tokenType: TokenType,
        isVaultFlow: Bool,
        sessionID: String?
    ) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }

        // Drop malformed items (e.g. from a "&&" in `base`), which `URLComponents`
        // parses as an empty-name, nil-value query item.
        var queryItems = (components.queryItems ?? []).filter { !$0.name.isEmpty }
        var additionalQueryItems: [URLQueryItem] = [
            URLQueryItem(name: Self.tokenQueryParameterName(for: tokenType), value: token),
            URLQueryItem(name: "source", value: "pda"),
            URLQueryItem(name: "merchant", value: clientID),
            URLQueryItem(name: "flow_type", value: (isVaultFlow ? FlowType.vault : .checkout).rawValue),
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
