import XCTest
@testable import PayPalPayments

class PayPalWebCheckoutURLBuilder_Tests: XCTestCase {

    private func queryValue(_ name: String, in url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }

    // MARK: - makeAppSwitchURL (checkout)

    func testMakeAppSwitchURL_checkout_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                token: "order-123",
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
        XCTAssertNil(queryValue("funding_source", in: url))
    }

    func testMakeAppSwitchURL_checkout_preservesExistingQueryOnBase() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(
                base: "https://sandbox.paypal.com/app-switch-checkout?existing=1"
            ).makeAppSwitchURL(
                clientID: "client-abc",
                token: "order-123",
                tokenType: .orderID,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("existing", in: url), "1")
        XCTAssertEqual(queryValue("token", in: url), "order-123")
    }

    func testMakeAppSwitchURL_checkout_percentEncodesSpecialCharacters() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client & co",
                token: "order-123",
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

    func testMakeAppSwitchURL_checkout_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                token: "order-123",
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

    func testMakeAppSwitchURL_checkout_usesTokenQueryNameForBillingToken() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                token: "BA-123",
                tokenType: .billingToken,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("token", in: url), "BA-123")
        XCTAssertNil(queryValue("ba_token", in: url))
    }

    func testMakeAppSwitchURL_derivesVaultFlowTypeFromTokenType() throws {
        // flow_type is derived from tokenType, so a vault tokenType always yields "va".
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                token: "setup-token-123",
                tokenType: .vaultID,
                sessionID: nil
            )
        )

        XCTAssertEqual(queryValue("flow_type", in: url), "va")
        XCTAssertEqual(queryValue("approval_session_id", in: url), "setup-token-123")
    }

    // MARK: - makeAppSwitchURL (vault)

    func testMakeAppSwitchURL_vault_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").makeAppSwitchURL(
                clientID: "client-abc",
                token: "setup-token-123",
                tokenType: .vaultID,
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
        XCTAssertEqual(queryValue("shopperSessionId", in: url), "session-xyz")
    }

    func testMakeAppSwitchURL_vault_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").makeAppSwitchURL(
                clientID: "client-abc",
                token: "setup-token-123",
                tokenType: .vaultID,
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
