import XCTest
@testable import PaymentButtons

final class PaymentButtonAnalyticsEvent_Tests: XCTestCase {

    /// Locks the FPTI event name for every case. If you change a string here,
    /// you are changing an analytics contract that downstream dashboards depend on.
    func testEventName_matchesFPTIContract() {
        XCTAssertEqual(PaymentButtonAnalyticsEvent.initialized.eventName, "payment-button:initialized")
        XCTAssertEqual(PaymentButtonAnalyticsEvent.tapped.eventName, "payment-button:tapped")
    }
}
