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
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").checkoutAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                orderID: "order-123",
                tokenType: .orderID,
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
        XCTAssertEqual(queryValue("shopperSessionId", in: url), "session-xyz")
        XCTAssertEqual(queryValue("funding_source", in: url), "paypal")
    }

    func testCheckoutAppSwitchURL_setsFundingSourceFromParameter() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").checkoutAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypalCredit,
                orderID: "order-123",
                tokenType: .orderID,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("funding_source", in: url), "credit")
    }

    func testCheckoutAppSwitchURL_preservesExistingQueryOnBase() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(
                base: "https://sandbox.paypal.com/app-switch-checkout?existing=1"
            ).checkoutAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                orderID: "order-123",
                tokenType: .orderID,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("existing", in: url), "1")
        XCTAssertEqual(queryValue("token", in: url), "order-123")
    }

    func testCheckoutAppSwitchURL_percentEncodesSpecialCharacters() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").checkoutAppSwitchURL(
                clientID: "client & co",
                fundingSource: .paypal,
                orderID: "order-123",
                tokenType: .orderID,
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
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").checkoutAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                orderID: "order-123",
                tokenType: .orderID,
                sessionID: "session-xyz"
            )
        )

        let afterMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let rawValue = try XCTUnwrap(queryValue("switch_initiated_time", in: url))
        let switchInitiatedMillis = try XCTUnwrap(Int(rawValue))

        XCTAssertGreaterThanOrEqual(switchInitiatedMillis, beforeMillis)
        XCTAssertLessThanOrEqual(switchInitiatedMillis, afterMillis)
    }

    func testCheckoutAppSwitchURL_usesTokenQueryNameForBillingToken() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").checkoutAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                orderID: "BA-123",
                tokenType: .billingToken,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("token", in: url), "BA-123")
        XCTAssertNil(queryValue("ba_token", in: url))
    }

    // MARK: - vaultAppSwitchURL

    func testVaultAppSwitchURL_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").vaultAppSwitchURL(
                merchantID: "client-abc",
                fundingSource: .paypal,
                sessionID: "session-xyz",
                setupTokenID: "setup-token-123",
                tokenType: .vaultID
            )
        )

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "sandbox.paypal.com")
        XCTAssertEqual(url.path, "/app-switch-vault")
        XCTAssertEqual(queryValue("approval_session_id", in: url), "setup-token-123")
        XCTAssertEqual(queryValue("source", in: url), "pda")
        XCTAssertEqual(queryValue("merchant", in: url), "client-abc")
        XCTAssertEqual(queryValue("flow_type", in: url), "va")
        XCTAssertEqual(queryValue("shopperSessionId", in: url), "session-xyz")
        XCTAssertEqual(queryValue("funding_source", in: url), "paypal")
    }

    func testVaultAppSwitchURL_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").vaultAppSwitchURL(
                merchantID: "client-abc",
                fundingSource: .paypal,
                sessionID: "session-xyz",
                setupTokenID: "setup-token-123",
                tokenType: .vaultID
            )
        )

        let afterMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let rawValue = try XCTUnwrap(queryValue("switch_initiated_time", in: url))
        let switchInitiatedMillis = try XCTUnwrap(Int(rawValue))

        XCTAssertGreaterThanOrEqual(switchInitiatedMillis, beforeMillis)
        XCTAssertLessThanOrEqual(switchInitiatedMillis, afterMillis)
    }
}
