import XCTest
@testable import CardPayments

final class CardAnalyticsEvent_Tests: XCTestCase {

    /// Locks the FPTI event name for every case. If you change a string here,
    /// you are changing an analytics contract that downstream dashboards depend on.
    func testEventName_matchesFPTIContract() {
        XCTAssertEqual(CardAnalyticsEvent.approveOrderStarted.eventName, "card-payments:approve-order:started")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengeRequired.eventName, "card-payments:approve-order:auth-challenge-required")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengePresentationSucceeded.eventName, "card-payments:approve-order:auth-challenge-presentation:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengePresentationFailed.eventName, "card-payments:approve-order:auth-challenge-presentation:failed")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderSucceeded.eventName, "card-payments:approve-order:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderFailed.eventName, "card-payments:approve-order:failed")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengeSucceeded.eventName, "card-payments:approve-order:auth-challenge:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengeFailed.eventName, "card-payments:approve-order:auth-challenge:failed")
        XCTAssertEqual(CardAnalyticsEvent.approveOrderAuthChallengeCanceled.eventName, "card-payments:approve-order:auth-challenge:canceled")
        XCTAssertEqual(CardAnalyticsEvent.vaultStarted.eventName, "card-payments:vault-wo-purchase:started")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengeRequired.eventName, "card-payments:vault-wo-purchase:auth-challenge-required")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengePresentationSucceeded.eventName, "card-payments:vault-wo-purchase:auth-challenge-presentation:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengePresentationFailed.eventName, "card-payments:vault-wo-purchase:auth-challenge-presentation:failed")
        XCTAssertEqual(CardAnalyticsEvent.vaultSucceeded.eventName, "card-payments:vault-wo-purchase:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.vaultFailed.eventName, "card-payments:vault-wo-purchase:failed")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengeSucceeded.eventName, "card-payments:vault-wo-purchase:auth-challenge:succeeded")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengeFailed.eventName, "card-payments:vault-wo-purchase:auth-challenge:failed")
        XCTAssertEqual(CardAnalyticsEvent.vaultAuthChallengeCanceled.eventName, "card-payments:vault-wo-purchase:auth-challenge:canceled")
    }
}
