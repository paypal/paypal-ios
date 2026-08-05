import XCTest
@testable import CorePayments
@testable import PayPalPayments

class Environment_PayPalWebCheckout_Tests: XCTestCase {

    func testPayPalEnvironment_returnsCorrectBaseURL() {
        let sandbox = CoreEnvironment.sandbox
        let live = CoreEnvironment.live

        XCTAssertEqual(sandbox.payPalBaseURL.absoluteString, "https://www.sandbox.paypal.com")
        XCTAssertEqual(live.payPalBaseURL.absoluteString, "https://www.paypal.com")
    }
}
