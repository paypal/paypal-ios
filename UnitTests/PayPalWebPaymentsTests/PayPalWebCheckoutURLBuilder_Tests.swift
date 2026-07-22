import XCTest
@testable import PayPalWebPayments

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
                fundingSource: .paypal,
                token: "order-123",
                tokenType: .orderID,
                isVaultFlow: false,
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

    func testMakeAppSwitchURL_checkout_setsFundingSourceFromParameter() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypalCredit,
                token: "order-123",
                tokenType: .orderID,
                isVaultFlow: false,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("funding_source", in: url), "credit")
    }

    func testMakeAppSwitchURL_checkout_preservesExistingQueryOnBase() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(
                base: "https://sandbox.paypal.com/app-switch-checkout?existing=1"
            ).makeAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                token: "order-123",
                tokenType: .orderID,
                isVaultFlow: false,
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
                fundingSource: .paypal,
                token: "order-123",
                tokenType: .orderID,
                isVaultFlow: false,
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
                fundingSource: .paypal,
                token: "order-123",
                tokenType: .orderID,
                isVaultFlow: false,
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
                fundingSource: .paypal,
                token: "BA-123",
                tokenType: .billingToken,
                isVaultFlow: false,
                sessionID: "session-xyz"
            )
        )

        XCTAssertEqual(queryValue("token", in: url), "BA-123")
        XCTAssertNil(queryValue("ba_token", in: url))
    }

    func testMakeAppSwitchURL_forcesCheckoutFlowType_evenForVaultTokenType() throws {
        // The legacy PatchCCO app-switch-eligibility fallback always routes through the checkout
        // ("ecs") endpoint, even when the token being checked is a vault setup token.
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-checkout").makeAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                token: "setup-token-123",
                tokenType: .vaultID,
                isVaultFlow: false,
                sessionID: nil
            )
        )

        XCTAssertEqual(queryValue("flow_type", in: url), "ecs")
        XCTAssertEqual(queryValue("approval_session_id", in: url), "setup-token-123")
    }

    // MARK: - makeAppSwitchURL (vault)

    func testMakeAppSwitchURL_vault_setsExpectedQueryItems() throws {
        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").makeAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                token: "setup-token-123",
                tokenType: .vaultID,
                isVaultFlow: true,
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
        XCTAssertEqual(queryValue("funding_source", in: url), "paypal")
    }

    func testMakeAppSwitchURL_vault_setsSwitchInitiatedTimeNearNow() throws {
        let beforeMillis = Int(round(Date().timeIntervalSince1970 * 1000))

        let url = try XCTUnwrap(
            PayPalWebCheckoutURLBuilder(base: "https://sandbox.paypal.com/app-switch-vault").makeAppSwitchURL(
                clientID: "client-abc",
                fundingSource: .paypal,
                token: "setup-token-123",
                tokenType: .vaultID,
                isVaultFlow: true,
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
