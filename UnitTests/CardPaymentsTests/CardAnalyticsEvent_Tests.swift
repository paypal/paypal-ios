import XCTest
@testable import CardPayments

final class CardAnalyticsEvent_Tests: XCTestCase {

    /// Locks the FPTI event name for every case. If you change a string here,
    /// you are changing an analytics contract that downstream dashboards depend on.
    func testApproveOrderEventNames_matchFPTIContract() {
        let approveOrder = CardAnalyticsEvent.ApproveOrder.self
        XCTAssertEqual(approveOrder.started.eventName, "card-payments:approve-order:started")
        XCTAssertEqual(approveOrder.authChallengeRequired.eventName, "card-payments:approve-order:auth-challenge-required")
        XCTAssertEqual(
            approveOrder.authChallengePresentationSucceeded.eventName,
            "card-payments:approve-order:auth-challenge-presentation:succeeded"
        )
        XCTAssertEqual(
            approveOrder.authChallengePresentationFailed.eventName,
            "card-payments:approve-order:auth-challenge-presentation:failed"
        )
        XCTAssertEqual(approveOrder.succeeded.eventName, "card-payments:approve-order:succeeded")
        XCTAssertEqual(approveOrder.failed.eventName, "card-payments:approve-order:failed")
        XCTAssertEqual(approveOrder.authChallengeSucceeded.eventName, "card-payments:approve-order:auth-challenge:succeeded")
        XCTAssertEqual(approveOrder.authChallengeFailed.eventName, "card-payments:approve-order:auth-challenge:failed")
        XCTAssertEqual(approveOrder.authChallengeCanceled.eventName, "card-payments:approve-order:auth-challenge:canceled")
    }

    func testVaultEventNames_matchFPTIContract() {
        let vault = CardAnalyticsEvent.Vault.self
        XCTAssertEqual(vault.started.eventName, "card-payments:vault-wo-purchase:started")
        XCTAssertEqual(vault.authChallengeRequired.eventName, "card-payments:vault-wo-purchase:auth-challenge-required")
        XCTAssertEqual(
            vault.authChallengePresentationSucceeded.eventName,
            "card-payments:vault-wo-purchase:auth-challenge-presentation:succeeded"
        )
        XCTAssertEqual(
            vault.authChallengePresentationFailed.eventName,
            "card-payments:vault-wo-purchase:auth-challenge-presentation:failed"
        )
        XCTAssertEqual(vault.succeeded.eventName, "card-payments:vault-wo-purchase:succeeded")
        XCTAssertEqual(vault.failed.eventName, "card-payments:vault-wo-purchase:failed")
        XCTAssertEqual(vault.authChallengeSucceeded.eventName, "card-payments:vault-wo-purchase:auth-challenge:succeeded")
        XCTAssertEqual(vault.authChallengeFailed.eventName, "card-payments:vault-wo-purchase:auth-challenge:failed")
        XCTAssertEqual(vault.authChallengeCanceled.eventName, "card-payments:vault-wo-purchase:auth-challenge:canceled")
    }
}
