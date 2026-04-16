import XCTest
@testable import PayPalWebPayments

final class PayPalWebAnalyticsEvent_Tests: XCTestCase {

    /// Locks the FPTI event name for every case. If you change a string here,
    /// you are changing an analytics contract that downstream dashboards depend on.
    func testEventName_matchesFPTIContract() {
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutStarted.eventName, "paypal-web-payments:checkout:started")
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutAuthChallengePresentationSucceeded.eventName, "paypal-web-payments:checkout:auth-challenge-presentation:succeeded")
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutAuthChallengePresentationFailed.eventName, "paypal-web-payments:checkout:auth-challenge-presentation:failed")
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutSucceeded.eventName, "paypal-web-payments:checkout:succeeded")
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutFailed.eventName, "paypal-web-payments:checkout:failed")
        XCTAssertEqual(PayPalWebAnalyticsEvent.checkoutCanceled.eventName, "paypal-web-payments:checkout:canceled")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultStarted.eventName, "paypal-web-payments:vault-wo-purchase:started")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultAuthChallengePresentationSucceeded.eventName, "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:succeeded")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultAuthChallengePresentationFailed.eventName, "paypal-web-payments:vault-wo-purchase:auth-challenge-presentation:failed")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultSucceeded.eventName, "paypal-web-payments:vault-wo-purchase:succeeded")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultFailed.eventName, "paypal-web-payments:vault-wo-purchase:failed")
        XCTAssertEqual(PayPalWebAnalyticsEvent.vaultCanceled.eventName, "paypal-web-payments:vault-wo-purchase:canceled")
    }
}
