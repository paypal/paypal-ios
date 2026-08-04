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
    /// Builds the app-switch URL for the checkout or vault-without-purchase flow.
    /// - Returns: `nil` if `base` isn't a valid URL string.
    func makeAppSwitchURL(
        clientID: String,
        token: String,
        tokenType: TokenType,
        sessionID: String?
    ) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }

        // Drop malformed items (e.g. from a "&&" in `base`), which `URLComponents`
        // parses as an empty-name, nil-value query item.
        var queryItems = (components.queryItems ?? []).filter { !$0.name.isEmpty }

        if !queryItems.contains(where: { $0.name == tokenType.tokenQueryParameterName }) {
            queryItems.append(URLQueryItem(name: tokenType.tokenQueryParameterName, value: token))
        }

        var additionalQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "source", value: "pda"),
            URLQueryItem(name: "merchant", value: clientID),
            URLQueryItem(name: "flow_type", value: flowType(for: tokenType).rawValue),
            URLQueryItem(name: "switch_initiated_time", value: String(Int(round(Date().timeIntervalSince1970 * 1000))))
        ]
        if let sessionID = sessionID {
            additionalQueryItems.append(URLQueryItem(name: "shopperSessionId", value: sessionID))
        }
        queryItems.append(contentsOf: additionalQueryItems)
        components.queryItems = queryItems

        return components.url
    }

    private func flowType(for tokenType: TokenType) -> FlowType {
        switch tokenType {
        case .orderID, .billingToken: return .checkout
        case .vaultID: return .vault
        }
    }
}

extension TokenType {

    var tokenQueryParameterName: String {
        switch self {
        case .orderID: return "token"
        case .vaultID: return "approval_session_id"
        case .billingToken: return "token"
        }
    }
}
