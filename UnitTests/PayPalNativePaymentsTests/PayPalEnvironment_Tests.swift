import XCTest
@testable import CorePayments
@testable import PayPalNativePayments

class PayPalEnvironment_Tests: XCTestCase {

    func testPayPalEnvironment_convertsToPayPalCheckoutEnvironmentCorrectly() {
        let sandbox = Environment.sandbox
        let prod = Environment.production

        XCTAssertEqual(sandbox.toNativeCheckoutSDKEnvironment(), .sandbox)
        XCTAssertEqual(prod.toNativeCheckoutSDKEnvironment(), .live)
    }
}
