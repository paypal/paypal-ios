import XCTest
@testable import PaymentsCore
@testable import PayPalNativeCheckout

class PayPalEnvironment_Tests: XCTestCase {

    func testPayPalEnvironment_convertsToPayPalCheckoutEnvironmentCorrectly() {
        let sandbox = Environment.sandbox
        let prod = Environment.production

        XCTAssertEqual(sandbox.toNativeCheckoutSDKEnvironment(), .sandbox)
        XCTAssertEqual(prod.toNativeCheckoutSDKEnvironment(), .live)
    }
}
