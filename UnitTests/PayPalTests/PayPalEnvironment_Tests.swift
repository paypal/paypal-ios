import XCTest
@testable import PaymentsCore
@testable import PayPal

class PayPalEnvironment_Tests: XCTestCase {

    func testPayPalEnvironment_returnsCorrectBaseURL() {
        let sandbox = Environment.sandbox
        let production = Environment.production

        XCTAssertEqual(sandbox.payPalBaseURL.absoluteString, "https://sandbox.paypal.com")
        XCTAssertEqual(production.payPalBaseURL.absoluteString, "https://paypal.com")
    }
}
