import Foundation

/// Builds the deep-link URLs used to app-switch into the PayPal app for checkout and vault flows.
enum PayPalWebCheckoutURLBuilder {

    static func checkoutAppSwitchURL(
        base: String,
        orderID: String,
        clientID: String,
        sessionID: String
    ) -> String {
        //TODO: append sessionID. &sessionID=\(sessionID)
        "\(base)?token=\(orderID)&source=pda&merchant=\(clientID)&flow_type=ecs"
    }

    static func vaultAppSwitchURL(
        base: String,
        setupTokenID: String,
        clientID: String,
        sessionID: String
    ) -> String {
        "\(base)?approval_session_id=\(setupTokenID)&source=pda&flow_type=va&merchant=\(clientID)"
    }
}
