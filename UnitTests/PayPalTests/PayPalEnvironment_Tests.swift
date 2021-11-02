import XCTest
@testable import PaymentsCore
@testable import PayPal

class PayPalEnvironment_Tests: XCTestCase {

    func testPayPalEnvironment_convertsToPayPalCheckoutEnvironmentCorrectly() {
        let sandbox = Environment.sandbox
        let prod = Environment.production

        XCTAssertEqual(sandbox.toPayPalCheckoutEnvironment(), .sandbox)
        XCTAssertEqual(prod.toPayPalCheckoutEnvironment(), .live)
    }
}
