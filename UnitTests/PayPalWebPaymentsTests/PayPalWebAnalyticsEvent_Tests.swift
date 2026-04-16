import XCTest
@testable import PayPalWebPayments

final class PayPalWebAnalyticsEvent_Tests: XCTestCase {

    /// Locks the FPTI event name for every case. If you change a string here,
    /// you are changing an analytics contract that downstream dashboards depend on.
    func testCheckoutEventNames_matchFPTIContract() {
        let checkout = PayPalWebAnalyticsEvent.Checkout.self
        XCTAssertEqual(checkout.started.eventName, "paypal-web-payments:checkout:started")
        XCTAssertEqual(
            checkout.authChallengePresentationSucceeded.eventName,
            "paypal-web-payments:checkout:auth-challenge-presentation:succeeded"
        )
        XCTAssertEqual(
            checkout.authChallengePresentationFailed.eventName,
            "paypal-web-payments:checkout:auth-challenge-presentation:failed"
        )
        XCTAssertEqual(checkout.succeeded.eventName, "paypal-web-payments:checkout:succeeded")
        XCTAssertEqual(checkout.failed.eventName, "paypal-web-payments:checkout:failed")
        XCTAssertEqual(checkout.canceled.eventName, "paypal-web-payments:checkout:canceled")
    }

    func testVaultEventNames_matchFPTIContract() {
        let vault = PayPalWebAnalyticsEvent.Vault.self
        XCTAssertEqual(vault.started.eventName, "paypal-web-payments:vault-wo-purchase:started")
        XCTAssertEqual(
            vault.authChallengePresentationSucceeded.eventName,
            "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
        )
        XCTAssertEqual(
            vault.authChallengePresentationFailed.eventName,
            "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed"
        )
        XCTAssertEqual(vault.succeeded.eventName, "paypal-web-payments:vault-wo-purchase:succeeded")
        XCTAssertEqual(vault.failed.eventName, "paypal-web-payments:vault-wo-purchase:failed")
        XCTAssertEqual(vault.canceled.eventName, "paypal-web-payments:vault-wo-purchase:canceled")
    }
}
