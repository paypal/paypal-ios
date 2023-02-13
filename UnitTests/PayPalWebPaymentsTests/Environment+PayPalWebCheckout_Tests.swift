import XCTest
@testable import CorePayments
@testable import PayPalWebPayments

class Environment_PayPalWebCheckout_Tests: XCTestCase {

    func testPayPalEnvironment_returnsCorrectBaseURL() {
        let sandbox = Environment.sandbox
        let live = Environment.live

        XCTAssertEqual(sandbox.payPalBaseURL.absoluteString, "https://www.sandbox.paypal.com")
        XCTAssertEqual(live.payPalBaseURL.absoluteString, "https://www.paypal.com")
    }
}
