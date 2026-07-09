import XCTest
@testable import PayPalWebPayments

class PayPalWebCheckoutURLBuilder_Tests: XCTestCase {

    private func queryValue(_ name: String, in url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }

    // MARK: - checkoutAppSwitchURL

    func testCheckoutAppSwitchURL_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-checkout",
                orderID: "order-123",
                clientID: "client-abc",
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "sandbox.paypal.com")
        XCTAssertEqual(url.path, "/app-switch-checkout")
        XCTAssertEqual(queryValue("token", in: url), "order-123")
        XCTAssertEqual(queryValue("source", in: url), "pda")
        XCTAssertEqual(queryValue("merchant", in: url), "client-abc")
        XCTAssertEqual(queryValue("flow_type", in: url), "ecs")
        XCTAssertEqual(queryValue("shoppersSessionId", in: url), "session-xyz")
    }

    func testCheckoutAppSwitchURL_preservesExistingQueryOnBase() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-checkout?existing=1",
                orderID: "order-123",
                clientID: "client-abc",
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("existing", in: url), "1")
        XCTAssertEqual(queryValue("token", in: url), "order-123")
    }

    func testCheckoutAppSwitchURL_percentEncodesSpecialCharacters() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-checkout",
                orderID: "order-123",
                clientID: "client & co",
                sessionID: "session-xyz"
            )
        )

        // Decoded query value round-trips to the original, unescaped string.
        XCTAssertEqual(queryValue("merchant", in: url), "client & co")
        // The raw query string must not contain a bare, unescaped "&" from the value
        // (which would otherwise be mis-parsed as a new query parameter).
        XCTAssertFalse(url.query?.contains("client & co") ?? true)
    }

    func testCheckoutAppSwitchURL_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.checkoutAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-checkout",
                orderID: "order-123",
                clientID: "client-abc",
                sessionID: "session-xyz"
            )
        )

        let afterMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let rawValue = try XCTUnwrap(queryValue("switch_initiated_time", in: url))
        let switchInitiatedMillis = try XCTUnwrap(Int(rawValue))

        XCTAssertGreaterThanOrEqual(switchInitiatedMillis, beforeMillis)
        XCTAssertLessThanOrEqual(switchInitiatedMillis, afterMillis)
    }

    // MARK: - vaultAppSwitchURL

    func testVaultAppSwitchURL_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-vault",
                setupTokenID: "setup-token-123",
                clientID: "client-abc",
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "sandbox.paypal.com")
        XCTAssertEqual(url.path, "/app-switch-vault")
        XCTAssertEqual(queryValue("approval_session_id", in: url), "setup-token-123")
        XCTAssertEqual(queryValue("source", in: url), "pda")
        XCTAssertEqual(queryValue("merchant", in: url), "client-abc")
        XCTAssertEqual(queryValue("flow_type", in: url), "va")
        XCTAssertEqual(queryValue("shoppersSessionId", in: url), "session-xyz")
    }

    func testVaultAppSwitchURL_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder.vaultAppSwitchURL(
                base: "https://sandbox.paypal.com/app-switch-vault",
                setupTokenID: "setup-token-123",
                clientID: "client-abc",
                sessionID: "session-xyz"
            )
        )

        let afterMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let rawValue = try XCTUnwrap(queryValue("switch_initiated_time", in: url))
        let switchInitiatedMillis = try XCTUnwrap(Int(rawValue))

        XCTAssertGreaterThanOrEqual(switchInitiatedMillis, beforeMillis)
        XCTAssertLessThanOrEqual(switchInitiatedMillis, afterMillis)
    }
}
