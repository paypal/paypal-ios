import Foundation

enum PayPalWebCheckoutURLBuilder {

    static func checkoutAppSwitchURL(
        base: String,
        orderID: String,
        clientID: String,
        sessionID: String
    ) -> String {
        "\(base)?token=\(orderID)&source=pda&merchant=\(clientID)&flow_type=ecs&sessionID=\(sessionID)"
    }

    static func checkoutBrowserURL(base: String, orderID: String, sessionID: String) -> String {
        "\(base)?token=\(orderID)&sessionID=\(sessionID)"
    }

    static func vaultAppSwitchURL(
        base: String,
        setupTokenID: String,
        clientID: String,
        sessionID: String
    ) -> String {
        "\(base)?approval_session_id=\(setupTokenID)&source=pda&flow_type=va&merchant=\(clientID)&sessionID=\(sessionID)"
    }

    static func vaultBrowserURL(base: String, setupTokenID: String, sessionID: String) -> String {
        "\(base)?approval_session_id=\(setupTokenID)&sessionID=\(sessionID)"
    }
}
