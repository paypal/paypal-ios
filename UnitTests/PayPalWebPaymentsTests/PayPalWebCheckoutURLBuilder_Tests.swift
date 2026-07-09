import XCTest
@testable import PayPalWebPayments

class PayPalWebCheckoutURLBuilder_Tests: XCTestCase {

    func testCheckoutAppSwitchURL_buildsExpectedURLString() {
        let urlString = PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
            base: "https://sandbox.paypal.com/app-switch-checkout",
            orderID: "order-123",
            clientID: "client-abc",
            sessionID: "session-xyz"
        )

        XCTAssertEqual(
            urlString,
            "https://sandbox.paypal.com/app-switch-checkout?token=order-123&source=pda&merchant=client-abc" +
                "&flow_type=ecs&sessionID=session-xyz"
        )
    }

    func testCheckoutAppSwitchURL_producesValidURL() {
        let urlString = PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
            base: "https://sandbox.paypal.com/app-switch-checkout",
            orderID: "order-123",
            clientID: "client-abc",
            sessionID: "session-xyz"
        )

        XCTAssertNotNil(URL(string: urlString))
    }

    func testVaultAppSwitchURL_buildsExpectedURLString() {
        let urlString = PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
            base: "https://sandbox.paypal.com/app-switch-vault",
            setupTokenID: "setup-token-123",
            clientID: "client-abc",
            sessionID: "session-xyz"
        )

        XCTAssertEqual(
            urlString,
            "https://sandbox.paypal.com/app-switch-vault?approval_session_id=setup-token-123&source=pda" +
                "&flow_type=va&merchant=client-abc&sessionID=session-xyz"
        )
    }

    func testVaultAppSwitchURL_producesValidURL() {
        let urlString = PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
            base: "https://sandbox.paypal.com/app-switch-vault",
            setupTokenID: "setup-token-123",
            clientID: "client-abc",
            sessionID: "session-xyz"
        )

        XCTAssertNotNil(URL(string: urlString))
    }
}
