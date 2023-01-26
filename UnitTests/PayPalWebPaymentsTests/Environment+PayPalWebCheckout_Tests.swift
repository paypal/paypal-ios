import XCTest
@testable import PaymentsCore
@testable import PayPalWebPayments

class Environment_PayPalWebCheckout_Tests: XCTestCase {

    func testPayPalEnvironment_returnsCorrectBaseURL() {
        let sandbox = Environment.sandbox
        let production = Environment.production

        XCTAssertEqual(sandbox.payPalBaseURL.absoluteString, "https://www.sandbox.paypal.com")
        XCTAssertEqual(production.payPalBaseURL.absoluteString, "https://www.paypal.com")
    }
}
